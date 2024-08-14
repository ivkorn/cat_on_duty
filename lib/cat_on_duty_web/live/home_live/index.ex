defmodule CatOnDutyWeb.HomeLive.Index do
  @moduledoc false
  use CatOnDutyWeb, :live_view

  @impl true
  def render(assigns) do
    ~H""
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, push_navigate(socket, to: ~p"/teams")}
  end
end
