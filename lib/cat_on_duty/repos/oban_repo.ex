defmodule CatOnDuty.ObanRepo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :cat_on_duty,
    adapter: Ecto.Adapters.SQLite3
end
