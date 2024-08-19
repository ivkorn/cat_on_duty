defmodule CatOnDutyWeb.Plugs.Auth do
  @moduledoc false
  @behaviour Plug

  @impl Plug
  @spec init(Plug.opts()) :: Plug.opts()
  def init(options), do: options

  @impl Plug
  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts), do: Plug.BasicAuth.basic_auth(conn, Application.fetch_env!(:cat_on_duty, :basic_auth))
end
