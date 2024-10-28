defmodule CatOnDuty.Employees do
  @moduledoc "Team and Sentry context"

  import Ecto.Query, warn: false

  alias CatOnDuty.Employees.Sentry
  alias CatOnDuty.Employees.Team
  alias CatOnDuty.Repo

  @topic inspect(__MODULE__)

  # Socket

  @spec subscribe :: :ok | {:error, {:already_registered, pid}}
  def subscribe, do: Phoenix.PubSub.subscribe(CatOnDuty.PubSub, @topic)

  @spec broadcast_change({:ok, Sentry.t() | Team.t()} | {:error, Ecto.Changeset.t()}, [atom, ...]) ::
          {:ok, Sentry.t() | Team.t()} | {:error, Ecto.Changeset.t()}
  defp broadcast_change({:ok, result}, event) do
    :ok = Phoenix.PubSub.broadcast(CatOnDuty.PubSub, @topic, {__MODULE__, event, result})

    {:ok, result}
  end

  defp broadcast_change({:error, changeset}, _event), do: {:error, changeset}

  # Team

  @spec list_teams(Ecto.Query.t() | module) :: [Team.t()] | []
  def list_teams(query \\ Team) do
    query
    |> order_by(asc: :id)
    |> Repo.all()
    |> Repo.preload([:today_sentry])
  end

  @spec filter_teams(String.t()) :: [Team.t()] | []
  def filter_teams(search_term) do
    wildcard_search = String.downcase("%#{search_term}%")

    query = from(t in Team, where: like(fragment("lower(?)", t.name), ^wildcard_search))

    list_teams(query)
  end

  @spec get_team!(pos_integer) :: Team.t()
  def get_team!(id) do
    sentries_query =
      from(s in Sentry,
        order_by: [:on_vacation?, :last_duty_at]
      )

    team_query =
      from(t in Team,
        preload: [sentries: ^sentries_query],
        preload: :today_sentry
      )

    Repo.get!(team_query, id)
  end

  @spec create_team(map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, Repo.preload(schema, :today_sentry)}
      error -> error
    end
    |> broadcast_change([:team, :created])
  end

  @spec update_team(Team.t(), map) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:team, :updated])
  end

  @spec update_team_today_sentry(Team.t(), map) ::
          {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update_team_today_sentry(%Team{} = team, attrs) do
    team
    |> Team.today_sentry_changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:team, :updated])
  end

  @spec delete_team(Team.t()) :: {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def delete_team(%Team{} = team) do
    team
    |> Repo.delete()
    |> broadcast_change([:team, :deleted])
  end

  @spec change_team(Team.t(), map) :: Ecto.Changeset.t()
  def change_team(%Team{} = team, attrs \\ %{}), do: Team.changeset(team, attrs)

  # Sentry

  @spec list_sentries(Ecto.Query.t() | module) :: [Sentry.t()] | []
  def list_sentries(query \\ Sentry) do
    query
    |> order_by(asc: :id)
    |> Repo.all()
    |> Repo.preload(:team)
  end

  @spec filter_sentries(String.t()) :: [Sentry.t()] | []
  def filter_sentries(search_term) do
    wildcard_search = String.downcase("%#{search_term}%")

    query =
      from(s in Sentry,
        where: like(fragment("lower(?)", s.name), ^wildcard_search),
        or_where: like(fragment("lower(?)", s.tg_username), ^wildcard_search)
      )

    list_sentries(query)
  end

  @spec team_sentries_not_on_vacation_sorted_by_last_duty_at(pos_integer) :: [Sentry.t()] | []
  def team_sentries_not_on_vacation_sorted_by_last_duty_at(team_id) do
    Sentry
    |> where([s], s.team_id == ^team_id)
    |> where([s], not s.on_vacation?)
    |> Repo.all()
    |> Enum.sort_by(&last_duty_at(&1))
  end

  @spec last_duty_at(Sentry.t()) :: :calendar.date() | nil
  defp last_duty_at(%Sentry{} = sentry) do
    case sentry.last_duty_at do
      nil -> nil
      date -> Date.to_erl(date)
    end
  end

  @spec get_sentry!(pos_integer) :: Sentry.t()
  def get_sentry!(id) do
    Sentry
    |> Repo.get!(id)
    |> Repo.preload(:team)
  end

  @spec create_sentry(map) :: {:ok, Sentry.t()} | {:error, Ecto.Changeset.t()}
  def create_sentry(attrs \\ %{}) do
    %Sentry{}
    |> Sentry.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, Repo.preload(schema, :team)}
      error -> error
    end
    |> broadcast_change([:sentry, :created])
  end

  @spec update_sentry(Sentry.t(), map) :: {:ok, Sentry.t()} | {:error, Ecto.Changeset.t()}
  def update_sentry(%Sentry{} = sentry, attrs) do
    sentry
    |> Sentry.changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:sentry, :updated])
  end

  @spec update_sentry_last_duty_at(Sentry.t(), map) ::
          {:ok, Sentry.t()} | {:error, Ecto.Changeset.t()}
  def update_sentry_last_duty_at(%Sentry{} = sentry, attrs) do
    sentry
    |> Sentry.last_duty_at_changeset(attrs)
    |> Repo.update()
    |> broadcast_change([:sentry, :updated])
  end

  @spec delete_sentry(Sentry.t()) :: {:ok, Sentry.t()} | {:error, Ecto.Changeset.t()}
  def delete_sentry(%Sentry{} = sentry) do
    sentry
    |> Repo.delete()
    |> broadcast_change([:sentry, :deleted])
  end

  @spec change_sentry(Sentry.t(), map) :: Ecto.Changeset.t()
  def change_sentry(%Sentry{} = sentry, attrs \\ %{}), do: Sentry.changeset(sentry, attrs)
end
