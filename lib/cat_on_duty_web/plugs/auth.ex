defmodule CatOnDutyWeb.Plugs.Auth do
  @moduledoc false

  def init(options), do: options

  def call(conn, _opts), do: Plug.BasicAuth.basic_auth(conn, Application.fetch_env!(:cat_on_duty, :basic_auth))
end
