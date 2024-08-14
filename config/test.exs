import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :cat_on_duty, CatOnDuty.Repo,
  username: "postgres",
  password: "postgres",
  database: "cat_on_duty_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  http: [port: 4002],
  server: false

config :cat_on_duty, Oban, testing: :inline

config :exvcr,
  vcr_cassette_library_dir: "test/fixtures/vcr_cassettes"

# Print only warnings and errors during test
config :logger, level: :warn
