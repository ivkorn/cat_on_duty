# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Use system sqlite3 library
System.put_env("EXQLITE_USE_SYSTEM", "1")

# Configures the endpoint
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  secret_key_base: "2jSx4UA7RbQ3kRY8erZoQfOgmrNfSmoP86B6ixAgBjaR/Aa7vC3m/rTTbpdDAX1D",
  render_errors: [
    formats: [html: CatOnDutyWeb.ErrorHTML],
    layout: false
  ],
  pubsub_server: CatOnDuty.PubSub,
  live_view: [signing_salt: "FKUqp7jQ"]

config :cat_on_duty, Oban,
  notifier: {Oban.Notifiers.Phoenix, pubsub: CatOnDuty.PubSub},
  engine: Oban.Engines.Lite,
  repo: CatOnDuty.ObanRepo,
  queues: [
    default: 5,
    rotation: 1
  ],
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"0 6 * * *", CatOnDuty.Workers.RotateAllSentries}
     ]}
  ]

config :cat_on_duty, :session_encryption_salt, "session_encryption_salt"
config :cat_on_duty, :session_signing_salt, "session_signing_salt"

# Configure your databases
config :cat_on_duty, [
  {CatOnDuty.ErrorTrackerRepo, priv: "priv/repos/error_tracker_repo"},
  {CatOnDuty.ObanRepo, priv: "priv/repos/oban_repo"},
  {CatOnDuty.Repo, priv: "priv/repos/repo"}
]

config :cat_on_duty,
  ecto_repos: [
    CatOnDuty.Repo,
    CatOnDuty.ErrorTrackerRepo,
    CatOnDuty.ObanRepo
  ]

config :error_tracker,
  repo: CatOnDuty.ErrorTrackerRepo,
  otp_app: :cat_on_duty,
  enabled: true

config :ex_gram, json_engine: JSON

config :exqlite, default_transaction_mode: :immediate

config :gettext, :default_locale, "ru"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, JSON

config :tesla, :adapter, {Tesla.Adapter.Finch, name: CatOnDuty.HTTP}

config :tower, reporters: [TowerErrorTracker], log_level: :error

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
