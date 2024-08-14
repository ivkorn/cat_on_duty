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
#     PHX_SERVER=true bin/actorrrate start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :actorrrate, CatOnDutyWeb.Endpoint, server: true
end

username = System.get_env("LOGIN", "login")
password = System.get_env("PASSWORD", "password")

config :cat_on_duty, :basic_auth, username: username, password: password

config :telegex, caller_adapter: Finch, token: System.get_env("TG_BOT_TOKEN")

if config_env() == :prod do
  secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
  host = System.get_env("PHX_HOST")
  port = String.to_integer(System.get_env("PORT") || "4000")
  database_url = System.fetch_env!("DATABASE_URL")
  db_pool_size = System.get_env("DB_POOL_SIZE", "18")
  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :cat_on_duty, CatOnDuty.Repo,
    ssl: true,
    url: database_url,
    pool_size: String.to_integer(db_pool_size)

  config :cat_on_duty, CatOnDutyWeb.Endpoint,
    url: [scheme: "https", host: host, port: 443],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base,
    socket_options: maybe_ipv6
end
