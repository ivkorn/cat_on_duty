defmodule CatOnDuty.Repo do
  use Ecto.Repo,
    otp_app: :cat_on_duty,
    adapter: Ecto.Adapters.SQLite3
end
