defmodule CatOnDuty.Repo.Migrations.AddTodaySentryToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :today_sentry_id, references(:sentries), on_delete: :nilify_all
    end
  end
end
