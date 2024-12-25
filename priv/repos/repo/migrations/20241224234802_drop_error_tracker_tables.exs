defmodule CatOnDuty.Repo.Migrations.DropErrorTrackerTables do
  use Ecto.Migration

  def up do
    drop table("error_tracker_errors")
    drop table("error_tracker_meta")
    drop table("error_tracker_occurrences")
  end

  def down, do: ErrorTracker.Migration.up(version: 4)
end
