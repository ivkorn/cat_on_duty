defmodule CatOnDuty.Repo.Migrations.DropObanTables do
  use Ecto.Migration

  def up do
    Oban.Migrations.down(version: 1)
  end

  def down do
    Oban.Migrations.up(version: 12)
  end
end
