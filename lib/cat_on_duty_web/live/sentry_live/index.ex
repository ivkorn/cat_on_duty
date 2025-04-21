defmodule CatOnDutyWeb.SentryLive.Index do
  @moduledoc "Sentry index page handlers"

  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Sentry
  alias Phoenix.LiveView.Socket

  defguardp empty_search?(socket) when socket.assigns.search.params == %{}

  @impl Phoenix.LiveView
  def mount(params, _session, socket) do
    if connected?(socket), do: Employees.subscribe()

    search_params = Map.take(params, ["name"])
    search = Map.get(params, "name", "")

    {:ok,
     socket
     |> assign(:search, to_form(search_params))
     |> stream(:sentries, Employees.filter_sentries(search))}
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
     |> stream(:sentries, Employees.filter_sentries(search), reset: true)
     |> push_patch(to: form_search_url(search))}
  end

  @spec apply_action(Socket.t(), :new_sentry | :index, String.t()) :: Socket.t()
  defp apply_action(socket, :new_sentry, _url) do
    socket
    |> assign(:page_title, dgettext("form", "New sentry"))
    |> assign(:sentry, %Sentry{})
  end

  defp apply_action(socket, :index, url) do
    return_to = url |> URI.parse() |> then(&if is_nil(&1.query), do: &1.path, else: "#{&1.path}?#{&1.query}")
    socket |> assign(:page_title, dgettext("sentry", "Sentries")) |> assign(:return_to, return_to)
  end

  @spec form_search_url(String.t()) :: String.t()
  defp form_search_url(""), do: ~p"/sentries"
  defp form_search_url(search) when is_binary(search), do: ~p"/sentries?name=#{search}"
end
