import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/cheap_tech start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.

config :cat_on_duty, CatOnDuty.Repo,
  load_extensions:
    (with {_family, os_type} <- :os.type(),
          [arch | _] <- :system_architecture |> :erlang.system_info() |> :string.tokens(~c"-") do
       :cat_on_duty |> Application.app_dir("priv/sqlite/#{os_type}-#{arch}/*.so") |> Path.wildcard()
     end)

if System.get_env("PHX_SERVER") do
  config :cat_on_duty, CatOnDutyWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
  host = System.get_env("PHX_HOST")
  port = String.to_integer(System.get_env("PORT") || "4000")
  database_path = System.fetch_env!("DATABASE_PATH")
  db_pool_size = System.get_env("DB_POOL_SIZE", "3")
  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  username = System.fetch_env!("LOGIN")
  password = System.fetch_env!("PASSWORD")
  session_encryption_salt = System.fetch_env!("SESSION_ENCRYPTION_SALT")
  session_signing_salt = System.fetch_env!("SESSION_SIGNING_SALT")
  live_view_signing_salt = System.fetch_env!("LIVE_VIEW_SIGNING_SALT")
  tg_bot_token = System.fetch_env!("TG_BOT_TOKEN")

  config :cat_on_duty, CatOnDuty.ErrorTrackerRepo,
    database: Path.join(database_path, "error_tracker.db"),
    pool_size: String.to_integer(db_pool_size)

  config :cat_on_duty, CatOnDuty.ObanRepo,
    database: Path.join(database_path, "oban.db"),
    pool_size: String.to_integer(db_pool_size)

  config :cat_on_duty, CatOnDuty.Repo,
    database: Path.join(database_path, "cat_on_duty.db"),
    pool_size: String.to_integer(db_pool_size)

  config :cat_on_duty, CatOnDutyWeb.Endpoint,
    url: [scheme: "https", host: host, port: 443],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base,
    socket_options: maybe_ipv6,
    live_view: [signing_salt: live_view_signing_salt]

  config :cat_on_duty, :basic_auth, username: username, password: password
  config :cat_on_duty, :session_encryption_salt, session_encryption_salt
  config :cat_on_duty, :session_signing_salt, session_signing_salt

  config :ex_gram, token: tg_bot_token
end
