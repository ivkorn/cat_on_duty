defmodule CatOnDuty.ErrorTrackerRepo.Migrations.CreateErrorTrackerTables do
  use Ecto.Migration

  def up, do: ErrorTracker.Migration.up(version: 4)

  def down do
    drop table("error_tracker_errors")
    drop table("error_tracker_meta")
    drop table("error_tracker_occurrences")
  end
end
