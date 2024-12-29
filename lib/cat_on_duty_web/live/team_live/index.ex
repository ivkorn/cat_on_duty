defmodule CatOnDutyWeb.TeamLive.Index do
  @moduledoc false
  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Team
  alias Phoenix.LiveView.Socket

  defguardp empty_search?(socket) when socket.assigns.search.params == %{}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket), do: Employees.subscribe()

    {:ok,
     socket
     |> assign(:search, to_form(%{}))
     |> stream(:teams, Employees.list_teams())}
  end

  @impl Phoenix.LiveView
  def handle_info({Employees, [:team, :created], team}, socket) when empty_search?(socket) do
    {:noreply, stream_insert(socket, :teams, team)}
  end

  def handle_info({Employees, [:team, :updated], team}, socket) when empty_search?(socket) do
    {:noreply, socket |> stream_delete(:teams, team) |> stream_insert(:teams, team, at: -1)}
  end

  def handle_info({Employees, [:team, :deleted], team}, socket) when empty_search?(socket) do
    {:noreply, stream_delete(socket, :teams, team)}
  end

  def handle_info({Employees, [:team | _], _}, socket), do: {:noreply, socket}

  def handle_info({Employees, [:sentry | _], _}, socket), do: {:noreply, socket}

  def handle_info({CatOnDutyWeb.TeamLive.FormComponent, {:saved, team}}, socket) do
    {:noreply, stream_insert(socket, :teams, team)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("search", %{"search" => term} = search, socket) do
    search_term = String.trim(term)

    {:noreply,
     socket
     |> assign(:search, to_form(search))
     |> stream(:teams, Employees.filter_teams(search_term), reset: true)}
  end

  @spec apply_action(Socket.t(), :index | :new, any()) :: Socket.t()
  def apply_action(socket, :index, _params), do: assign(socket, :page_title, dgettext("form", "Teams"))

  def apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("form", "New team"))
    |> assign(:team, %Team{})
  end
end
