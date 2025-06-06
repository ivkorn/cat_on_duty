import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  http: [port: 4001],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers:
    Enum.map(
      [
        ["./build", "--watch"]
      ],
      &{Path.join(Path.dirname(__DIR__), "process_wrapper"), &1}
    )

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :cat_on_duty, CatOnDutyWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/cat_on_duty_web/(live|views)/.*(ex)$",
      ~r"lib/cat_on_duty_web/templates/.*(eex)$"
    ]
  ]

config :cat_on_duty, :basic_auth, username: "l", password: "p"

# Configure your databases
config :cat_on_duty, [
  {CatOnDuty.ErrorTrackerRepo,
   database: "priv/db/error_tracker_dev.db", stacktrace: true, show_sensitive_data_on_connection_error: true, pool_size: 3},
  {CatOnDuty.Repo,
   database: "priv/db/cat_on_duty_dev.db", stacktrace: true, show_sensitive_data_on_connection_error: true, pool_size: 3},
  {CatOnDuty.ObanRepo,
   database: "priv/db/oban_dev.db", stacktrace: true, show_sensitive_data_on_connection_error: true, pool_size: 3}
]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
config :logger, level: :debug

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view, debug_heex_annotations: true, enable_expensive_runtime_checks: true
