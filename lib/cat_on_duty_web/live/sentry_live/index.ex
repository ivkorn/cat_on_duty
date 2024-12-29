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

    {:ok,
     socket
     |> assign(:search, to_form(%{}))
     |> stream(:sentries, Employees.list_sentries())}
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

  def handle_info({Employees, [:sentry | _], _}, socket), do: {:noreply, socket}

  def handle_info({Employees, [:team | _], _}, socket), do: {:noreply, socket}

  def handle_info({CatOnDutyWeb.SentryLive.FormComponent, {:saved, sentry}}, socket) do
    {:noreply, stream_insert(socket, :sentries, sentry)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket), do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl Phoenix.LiveView
  def handle_event("search", %{"search" => term} = search, socket) do
    search_term = String.trim(term)

    {:noreply,
     socket
     |> assign(:search, to_form(search))
     |> stream(:sentries, Employees.filter_sentries(search_term), reset: true)}
  end

  @spec apply_action(Socket.t(), :new_sentry | :index, map) ::
          Socket.t()
  defp apply_action(socket, :new_sentry, _params) do
    socket
    |> assign(:page_title, dgettext("form", "New sentry"))
    |> assign(:sentry, %Sentry{})
  end

  defp apply_action(socket, :index, _params), do: assign(socket, :page_title, dgettext("sentry", "Sentries"))
end
