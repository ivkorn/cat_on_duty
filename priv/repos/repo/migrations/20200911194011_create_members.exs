defmodule CatOnDuty.Repo.Migrations.CreateSentrys do
  use Ecto.Migration

  def change do
    create table(:sentries) do
      add :name, :string, null: false
      add :tg_username, :string, null: false
      add :on_vacation?, :boolean, null: false, default: false
      add :last_duty_at, :utc_datetime

      add :team_id, references(:teams), on_delete: :nilify_all

      timestamps()
    end
  end
end
