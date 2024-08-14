defmodule CatOnDutyWeb.Router do
  use CatOnDutyWeb, :router

  alias CatOnDutyWeb.Plugs

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CatOnDutyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CatOnDutyWeb do
    pipe_through :browser

    live "/", HomeLive.Index

    live "/teams", TeamLive.Index, :index
    live "/teams/new", TeamLive.Index, :new

    live "/teams/:id", TeamLive.Show, :show
    live "/teams/:id/edit", TeamLive.Show, :edit
    live "/teams/:id/new_sentry", TeamLive.Show, :new_sentry
    live "/teams/:id/edit_sentry/:sentry_id", TeamLive.Show, :edit_sentry

    live "/sentries", SentryLive.Index, :index
    live "/sentries/new", SentryLive.Index, :new_sentry

    live "/sentries/:id", SentryLive.Show, :show
    live "/sentries/:id/edit", SentryLive.Show, :edit_sentry
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:domclick_duty, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DomclickDutyWeb.Telemetry
      # forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
