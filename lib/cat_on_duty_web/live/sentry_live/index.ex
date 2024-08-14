defmodule CatOnDutyWeb.SentryLive.Index do
  @moduledoc "Sentry index page handlers"

  use CatOnDutyWeb, :live_view

  alias CatOnDuty.Employees
  alias CatOnDuty.Employees.Sentry
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
  def handle_info({Employees, [:sentry | _], _}, %{assigns: %{search: search}} = socket) when search != "",
    do: {:noreply, socket}

  def handle_info({Employees, [:team | _], _}, %{assigns: %{search: search}} = socket) when search != "",
    do: {:noreply, socket}

  def handle_info({Employees, [:sentry | _], _}, socket), do: {:noreply, local_fetch(socket)}

  def handle_info({Employees, [:team | _], _}, socket), do: {:noreply, local_fetch(socket)}

  @impl true
  def handle_params(params, _url, socket), do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event("search", %{"value" => term} = search, socket) do
    search_term = String.trim(term)

    {:noreply,
     socket
     |> assign(:search, to_form(search))
     |> assign(:sentries, Employees.filter_sentries(search_term))}
  end

  @spec apply_action(Socket.t(), :new_sentry | :index, map) ::
          Socket.t()
  defp apply_action(socket, :new_sentry, _params) do
    socket
    |> assign(:page_title, dgettext("form", "New sentry"))
    |> assign(:sentry, %Sentry{})
  end

  defp apply_action(socket, :index, _params), do: assign(socket, :page_title, dgettext("sentry", "Sentries"))

  @spec local_fetch(Socket.t()) :: Socket.t()
  defp local_fetch(socket), do: assign(socket, :sentries, Employees.list_sentries())
end
