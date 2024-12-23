import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
alias Ecto.Adapters.SQL.Sandbox

config :cat_on_duty, CatOnDuty.ErrorTrackerRepo,
  database: Path.expand("../priv/db/error_tracker_test.db", __DIR__),
  pool_size: 1,
  busy_timeout: 5000,
  cache_size: 1_000_000_000,
  temp_store: :memory,
  pool: Sandbox

config :cat_on_duty, CatOnDuty.ObanRepo,
  database: Path.expand("../priv/db/oban_test.db", __DIR__),
  pool_size: 1,
  busy_timeout: 5000,
  cache_size: 1_000_000_000,
  temp_store: :memory,
  pool: Sandbox

config :cat_on_duty, CatOnDuty.Repo,
  database: Path.expand("../priv/db/cat_on_duty_test.db", __DIR__),
  pool_size: 1,
  busy_timeout: 5000,
  cache_size: 1_000_000_000,
  temp_store: :memory,
  pool: Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  http: [port: 4002],
  server: false

config :cat_on_duty, Oban, testing: :inline

config :exvcr,
  vcr_cassette_library_dir: "test/fixtures/vcr_cassettes"

# Print only warnings and errors during test
config :logger, level: :warning
