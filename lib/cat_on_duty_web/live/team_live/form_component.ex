defmodule CatOnDutyWeb.TeamLive.FormComponent do
  @moduledoc "Team edit page handlers"

  use CatOnDutyWeb, :live_component

  import CatOnDutyWeb.CoreComponents

  alias CatOnDuty.Employees
  alias Phoenix.LiveView.Socket

  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Employees.change_team(team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn -> to_form(changeset) end)}
  end

  @impl true
  def handle_event("validate", %{"team" => team_params}, socket) do
    changeset =
      Employees.change_team(socket.assigns.team, team_params)

    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    save_team(socket, socket.assigns.action, team_params)
  end

  @spec save_team(Socket.t(), :edit | :new, map) ::
          {:noreply, Socket.t()}
  def save_team(socket, :edit, team_params) do
    case Employees.update_team(socket.assigns.team, team_params) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("flash", "Team changed"))
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def save_team(socket, :new, team_params) do
    case Employees.create_team(team_params) do
      {:ok, team} ->
        notify_parent({:saved, team})

        {:noreply,
         socket
         |> put_flash(:info, dgettext("flash", "Team added"))
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
