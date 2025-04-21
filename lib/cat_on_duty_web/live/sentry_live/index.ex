defmodule CatOnDutyWeb.SentryLive.Index do
  @moduledoc "Sentry index page handlers"

  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Sentry
  alias Phoenix.LiveView.Socket

  defguardp empty_search?(socket) when socket.assigns.search.params == %{}

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket), do: Employees.subscribe()
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({Employees, [:sentry, :created], sentry}, socket) when empty_search?(socket) do
    {:noreply, stream_insert(socket, :sentries, sentry)}
  end

  def handle_info({Employees, [:sentry, :updated], sentry}, socket) when empty_search?(socket) do
    {:noreply, socket |> stream_delete(:sentries, sentry) |> stream_insert(:sentries, sentry, at: -1)}
  end

  def handle_info({Employees, [:sentry, :deleted], sentry}, socket) when empty_search?(socket) do
    {:noreply, stream_delete(socket, :sentries, sentry)}
  end

  def handle_info({Employees, [:sentry | _notifications], _sentry}, socket), do: {:noreply, socket}

  def handle_info({Employees, [:team | _notifications], _team}, socket), do: {:noreply, socket}

  def handle_info({CatOnDutyWeb.SentryLive.FormComponent, {:saved, sentry}}, socket) do
    {:noreply, stream_insert(socket, :sentries, sentry)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, %{assigns: %{live_action: live_action}} = socket) do
    {:noreply, apply_action(socket, live_action, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("search", params, socket), do: {:noreply, push_patch(socket, to: form_search_url(params))}

  @spec apply_action(Socket.t(), :index | :new_sentry, map()) :: Socket.t()
  defp apply_action(socket, :index, params) do
    search = params |> Map.get("name", "") |> String.trim()

    socket
    |> assign(:search, to_form(params))
    |> assign(:return_to, form_search_url(params))
    |> stream(:sentries, Employees.filter_sentries(search), reset: true)
  end

  defp apply_action(socket, :new_sentry, _params) do
    socket |> assign(:page_title, dgettext("form", "New sentry")) |> assign(:sentry, %Sentry{})
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
    |> then(&~p"/sentries?#{&1}")
  end
end
