defmodule CatOnDuty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CatOnDuty.Repo,
      CatOnDuty.ObanRepo,
      CatOnDuty.ErrorTrackerRepo,
      {Ecto.Migrator, repos: Application.fetch_env!(:cat_on_duty, :ecto_repos), skip: skip_migrations?()},
      # Start the Telemetry supervisor
      CatOnDutyWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CatOnDuty.PubSub},
      # Start the Endpoint (http/https)
      CatOnDutyWeb.Endpoint,
      # Start a worker by calling: CatOnDuty.Worker.start_link(arg)
      # {CatOnDuty.Worker, arg}
      {Oban, Application.fetch_env!(:cat_on_duty, Oban)},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CatOnDuty.HTTP}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CatOnDuty.Supervisor]

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CatOnDutyWeb.Endpoint.config_change(changed, removed)

    :ok
  end

  def skip_migrations? do
    if System.get_env("MIX_ENV") == "prod", do: false, else: true
  end
end
