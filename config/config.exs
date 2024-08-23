# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  secret_key_base: "2jSx4UA7RbQ3kRY8erZoQfOgmrNfSmoP86B6ixAgBjaR/Aa7vC3m/rTTbpdDAX1D",
  render_errors: [view: CatOnDutyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CatOnDuty.PubSub,
  live_view: [signing_salt: "FKUqp7jQ"]

config :cat_on_duty, Oban,
  engine: Oban.Engines.Lite,
  repo: CatOnDuty.Repo,
  queues: [
    rotation: 1
  ],
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"0 7 * * *", CatOnDuty.Workers.RotateAllSentries}
     ]}
  ]

config :cat_on_duty, :basic_auth, username: "l", password: "p"
config :cat_on_duty, :session_encryption_salt, "session_encryption_salt"
config :cat_on_duty, :session_signing_salt, "session_signing_salt"

config :cat_on_duty,
  ecto_repos: [CatOnDuty.Repo]

config :gettext, :default_locale, "ru"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :telegex, caller_adapter: Finch

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
