defmodule CatOnDutyWeb.HomeLive.Index do
  @moduledoc false
  use CatOnDutyWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H""
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/teams")}
  end
end
