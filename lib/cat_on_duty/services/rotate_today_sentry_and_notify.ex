defmodule CatOnDuty.Services.RotateTodaySentryAndNotify do
  @moduledoc "Serviice that provides functions for rotation and team or all teams today sentry"

  import CatOnDutyWeb.Gettext

  alias CatOnDuty.BusinessCalendar
  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Sentry
  alias CatOnDuty.Employees.Team

  @spec for_all_teams :: {:ok, :rotated} | {:error, :not_business_day}
  def for_all_teams do
    if BusinessCalendar.working_day?(DateTime.utc_now()) do
      Enum.each(Employees.list_teams(), &for_team(&1.id))
      {:ok, :rotated}
    else
      {:error, :not_business_day}
    end
  end

  @spec for_team(pos_integer) :: {:ok, pid}
  def for_team(id) do
    Task.start_link(fn ->
      {:ok, _} =
        id
        |> Employees.get_team!()
        |> rotate_today_sentry()

      notify_about_new_today_sentry(id)
    end)
  end

  @spec rotate_today_sentry(Team.t()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  defp rotate_today_sentry(team) do
    case most_rested_team_sentry(team) do
      nil ->
        Employees.update_team_today_sentry(team, %{today_sentry_id: nil})

      %Sentry{} = most_rested ->
        {:ok, _} = Employees.update_sentry_last_duty_at(most_rested, %{last_duty_at: DateTime.utc_now()})

        Employees.update_team_today_sentry(team, %{today_sentry_id: most_rested.id})
    end
  end

  @spec most_rested_team_sentry(Team.t()) :: Sentry.t() | nil
  defp most_rested_team_sentry(%Team{id: id}) do
    case Employees.team_sentries_not_on_vacation_sorted_by_last_duty_at(id) do
      [] ->
        nil

      [most_rested | _] ->
        most_rested
    end
  end

  @spec notify_about_new_today_sentry(pos_integer) :: :ok | {:error, :not_sended}
  defp notify_about_new_today_sentry(id) do
    case Employees.get_team!(id) do
      %Team{today_sentry: %Sentry{}} = team ->
        notify(team, 0)

      _team_without_today_sentry ->
        {:ok, :no_sentry}
    end
  end

  @spec notify(Team.t(), 0..6) :: :ok | {:error, :not_sended}
  def notify(_team, 6), do: {:error, :not_sended}

  def notify(%Team{today_sentry: sentry, tg_chat_id: chat_id} = _team, _retry) do
    message =
      dgettext("telegram", "❗Today's duty is on %{name}(%{username})", name: sentry.name, username: sentry.tg_username)

    Telegex.send_message(String.to_integer(chat_id), message)
  end
end
