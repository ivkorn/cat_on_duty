defmodule CatOnDutyWeb.SentryLive.FormComponent do
  @moduledoc "Sentry edit page handlers"

  use CatOnDutyWeb, :live_component

  import CatOnDutyWeb.CoreComponents

  alias CatOnDuty.Employees
  alias Phoenix.LiveView.Socket

  @impl true
  def update(%{sentry: sentry} = assigns, socket) do
    changeset = Employees.change_sentry(sentry)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))
     |> assign(:teams, Employees.list_teams())}
  end

  @impl true
  def handle_event("validate", %{"sentry" => sentry_params}, socket) do
    changeset =
      socket.assigns.sentry
      |> Employees.change_sentry(sentry_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"sentry" => sentry_params}, socket) do
    save_sentry(socket, socket.assigns.action, sentry_params)
  end

  @spec save_sentry(Socket.t(), :edit_sentry | :new_sentry | :new, map) ::
          {:noreply, Socket.t()}
  defp save_sentry(socket, :edit_sentry, sentry_params) do
    case Employees.update_sentry(socket.assigns.sentry, sentry_params) do
      {:ok, _sentry} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("flash", "Sentry changed"))
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_sentry(socket, :new_sentry, sentry_params) do
    sentry_params
    |> Map.put("team_id", socket.assigns.team.id)
    |> handle_sentry_creation(socket)
  end

  defp save_sentry(socket, :new, sentry_params) do
    handle_sentry_creation(sentry_params, socket)
  end

  @spec handle_sentry_creation(map, Socket.t()) ::
          {:noreply, Socket.t()}
  defp handle_sentry_creation(sentry_params, socket) do
    case Employees.create_sentry(sentry_params) do
      {:ok, _sentry} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("flash", "Sentry added"))
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
