defmodule CatOnDuty.ErrorTrackerRepo.Migrations.AddErrorTrackerV5Fields do
  use Ecto.Migration

    def up, do: ErrorTracker.Migration.up(version: 5)

    def down, do: ErrorTracker.Migration.down(version: 5)
end
