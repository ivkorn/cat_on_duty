defmodule CatOnDutyWeb.TeamLive.Index do
  @moduledoc false
  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Team
  alias Phoenix.LiveView.Socket

  @impl true
  def mount(_params, _session, socket) do
    :ok = Employees.subscribe()

    {:ok,
     socket
     |> assign(:search, to_form(%{}))
     |> local_fetch()}
  end

  @impl true
  def handle_info({Employees, [:team | _], _}, %{assigns: %{search: search}} = socket) when search != "",
    do: {:noreply, socket}

  def handle_info({Employees, [:sentry | _], _}, %{assigns: %{search: search}} = socket) when search != "",
    do: {:noreply, socket}

  def handle_info({Employees, [:team | _], _}, socket), do: {:noreply, local_fetch(socket)}

  def handle_info({Employees, [:sentry | _], _}, socket), do: {:noreply, socket}

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("search", %{"value" => term} = search, socket) do
    search_term = String.trim(term)

    {:noreply,
     socket
     |> assign(:search, to_form(search))
     |> assign(:teams, Employees.filter_teams(search_term))}
  end

  def apply_action(socket, :index, _params), do: assign(socket, :page_title, dgettext("form", "Teams"))

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("form", "New team"))
    |> assign(:team, %Team{})
  end

  @spec local_fetch(Socket.t()) :: Socket.t()
  defp local_fetch(socket), do: assign(socket, :teams, Employees.list_teams())
end
