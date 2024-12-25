defmodule CatOnDuty.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string, null: false
      add :tg_chat_id, :string, null: false

      timestamps()
    end
  end
end
