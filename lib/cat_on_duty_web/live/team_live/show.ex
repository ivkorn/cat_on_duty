defmodule CatOnDutyWeb.TeamLive.Show do
  @moduledoc "Team show page handlers"

  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Sentry
  alias CatOnDuty.Employees.Team
  alias CatOnDuty.Services.RotateTodaySentryAndNotify
  alias Phoenix.LiveView.Socket

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Employees.subscribe()

    {:ok, local_fetch(socket, id)}
  end

  @impl Phoenix.LiveView
  def handle_info({Employees, [:team, :deleted], %{id: deleted_id}}, %{assigns: %{team: team}} = socket) do
    if deleted_id == team.id do
      {:noreply, push_navigate(socket, to: ~p"/teams")}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Employees, [:team | _notifications], %{id: updated_id}}, %{assigns: %{team: team}} = socket) do
    if updated_id == team.id do
      {:noreply, local_fetch(socket, team.id)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Employees, [:sentry | _notifications], _sentry}, %{assigns: %{team: team}} = socket),
    do: {:noreply, local_fetch(socket, team.id)}

  @impl Phoenix.LiveView
  def handle_params(%{"id" => id, "sentry_id" => sentry_id}, _url, socket) do
    team = Employees.get_team!(id)
    sentry = Employees.get_sentry!(sentry_id)

    {:noreply,
     socket
     |> assign(:team, team)
     |> apply_action(socket.assigns.live_action, sentry)}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    team = Employees.get_team!(id)

    {:noreply,
     socket
     |> assign(:team, team)
     |> apply_action(socket.assigns.live_action, team)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _team} =
      id
      |> Employees.get_team!()
      |> Employees.delete_team()

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Team deleted"))
     |> push_navigate(to: ~p"/teams")}
  end

  def handle_event("delete_sentry", %{"id" => id}, socket) do
    sentry = Employees.get_sentry!(id)

    {:ok, _sentry} = Employees.delete_sentry(sentry)

    team = Employees.get_team!(sentry.team_id)

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Sentry deleted"))
     |> assign(:team, team)}
  end

  def handle_event("rotate_today_sentry", %{"id" => id}, socket) do
    {:ok, _result} = RotateTodaySentryAndNotify.for_team(id)

    {:noreply,
     socket
     |> put_flash(:info, dgettext("flash", "Team today sentry rotated"))
     |> local_fetch(id)}
  end

  @spec apply_action(Socket.t(), :show | :edit | :new_sentry, map) ::
          Socket.t()
  defp apply_action(socket, :show, %Team{name: name}), do: assign(socket, :page_title, name)

  defp apply_action(socket, :edit, %Team{}), do: assign(socket, :page_title, dgettext("form", "Edit team"))

  defp apply_action(socket, :new_sentry, %Team{}) do
    socket
    |> assign(:page_title, dgettext("form", "New sentry"))
    |> assign(:sentry, %Sentry{})
  end

  defp apply_action(socket, :edit_sentry, %Sentry{} = sentry) do
    socket
    |> assign(:page_title, dgettext("form", "Edit sentry"))
    |> assign(:sentry, sentry)
  end

  @spec local_fetch(Socket.t(), pos_integer) :: Socket.t()
  defp local_fetch(socket, id), do: assign(socket, :team, Employees.get_team!(id))
end
