defmodule CatOnDutyWeb.TeamLive.Index do
  @moduledoc false
  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Team
  alias Phoenix.LiveView.Socket

  defguardp empty_search?(socket) when socket.assigns.search.params == %{}

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    if connected?(socket), do: Employees.subscribe()

    search_params = Map.take(params, ["name"])
    search = params |> Map.get("name", "") |> String.trim()

    {:ok,
     socket
     |> assign(:search, to_form(search_params))
     |> stream(:teams, Employees.filter_teams(search))}
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

  def handle_info({Employees, [:team | _notifications], _team}, socket), do: {:noreply, socket}

  def handle_info({Employees, [:sentry | _notifications], _sentry}, socket), do: {:noreply, socket}

  def handle_info({CatOnDutyWeb.TeamLive.FormComponent, {:saved, team}}, socket) do
    {:noreply, stream_insert(socket, :teams, team)}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, url, %{assigns: %{live_action: live_action}} = socket) do
    {:noreply, apply_action(socket, live_action, url)}
  end

  @impl Phoenix.LiveView
  def handle_event("search", params, socket) do
    search_params = Map.take(params, ["name"])
    search = params |> Map.get("name", "") |> String.trim()

    {:noreply,
     socket
     |> assign(:search, to_form(search_params))
     |> stream(:teams, Employees.filter_teams(search), reset: true)
     |> push_patch(to: form_search_url(search))}
  end

  @spec apply_action(Socket.t(), :index | :new, String.t()) :: Socket.t()
  defp apply_action(socket, :index, url) do
    return_to = url |> URI.parse() |> then(&if is_nil(&1.query), do: &1.path, else: "#{&1.path}?#{&1.query}")
    socket |> assign(:page_title, dgettext("form", "Teams")) |> assign(:return_to, return_to)
  end

  defp apply_action(socket, :new, _url) do
    socket
    |> assign(:page_title, dgettext("form", "New team"))
    |> assign(:team, %Team{})
  end

  @spec form_search_url(String.t()) :: String.t()
  defp form_search_url(""), do: ~p"/teams"
  defp form_search_url(search) when is_binary(search), do: ~p"/teams?name=#{search}"
end
