# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cat_on_duty,
  ecto_repos: [CatOnDuty.Repo]

# Configures the endpoint
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2jSx4UA7RbQ3kRY8erZoQfOgmrNfSmoP86B6ixAgBjaR/Aa7vC3m/rTTbpdDAX1D",
  render_errors: [view: CatOnDutyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CatOnDuty.PubSub,
  live_view: [signing_salt: "FKUqp7jQ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :gettext, :default_locale, "ru"

config :cat_on_duty, Oban,
  engine: Oban.Pro.Queue.SmartEngine,
  repo: CatOnDuty.Repo,
  queues: [
    rotation: 1
  ],
  plugins: [
    Oban.Plugins.Gossip,
    Oban.Pro.Plugins.DynamicLifeline,
    Oban.Web.Plugins.Stats,
    {Oban.Plugins.Cron,
     crontab: [
       {"0 7 * * *", CatOnDuty.Workers.RotateAllSentries}
     ]}
  ]

config :businex,
  calendars: %{
    business: CatOnDuty.BusinessCalendar
  },
  default_calendar: :business

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
