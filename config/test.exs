import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
alias Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  http: [port: 4002],
  server: false

config :cat_on_duty, Oban, testing: :inline
config :cat_on_duty, :basic_auth, username: "l", password: "p"

# Configure your databases
config :cat_on_duty, [
  {CatOnDuty.ErrorTrackerRepo,
   database: "priv/db/error_tracker_test.db",
   pool: Sandbox,
   stacktrace: true,
   show_sensitive_data_on_connection_error: true,
   pool_size: 1},
  {CatOnDuty.ObanRepo,
   database: "priv/db/oban_test.db",
   pool: Sandbox,
   stacktrace: true,
   show_sensitive_data_on_connection_error: true,
   pool_size: 1},
  {CatOnDuty.Repo,
   database: "priv/db/cat_on_duty_test.db",
   pool: Sandbox,
   stacktrace: true,
   show_sensitive_data_on_connection_error: true,
   pool_size: 1}
]

config :exqlite,
  busy_timeout: 5000,
  cache_size: 1_000_000_000,
  temp_store: :memory

config :exvcr,
  vcr_cassette_library_dir: "test/fixtures/vcr_cassettes"

# Print only warnings and errors during test
config :logger, level: :warning
