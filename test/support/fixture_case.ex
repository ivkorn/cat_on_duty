defmodule CatOnDuty.FixtureCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require fixtures.
  """

  use ExUnit.CaseTemplate

  setup_all do
    file_fixture_dir = Path.expand("test/fixtures/files/")

    file_fixture = fn file_fixture_path ->
      [file_fixture_dir, file_fixture_path] |> Path.join() |> File.read!()
    end

    {:ok, file_fixture: file_fixture}
  end
end
