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
    {:ok, socket}
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
  def handle_params(params, _url, %{assigns: %{live_action: live_action}} = socket) do
    {:noreply, apply_action(socket, live_action, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("search", params, socket), do: {:noreply, push_patch(socket, to: form_search_url(params))}

  @spec apply_action(Socket.t(), :index | :new, map()) :: Socket.t()
  defp apply_action(socket, :index, params) do
    search = params |> Map.get("name", "") |> String.trim()

    socket
    |> assign(:search, to_form(params))
    |> assign(:return_to, form_search_url(params))
    |> stream(:teams, Employees.filter_teams(search), reset: true)
  end

  defp apply_action(socket, :new, _params) do
    socket |> assign(:page_title, dgettext("form", "New team")) |> assign(:team, %Team{})
  end

  @spec form_search_url(map()) :: String.t()
  defp form_search_url(%{} = params) do
    params
    |> Enum.filter(fn
      {"_" <> _rest_key, _value} -> false
      {_key, ""} -> false
      _other -> true
    end)
    |> Map.new()
    |> then(&~p"/teams?#{&1}")
  end
end
