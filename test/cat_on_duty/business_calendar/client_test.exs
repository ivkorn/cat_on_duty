defmodule CatOnDuty.BusinessCalendar.ClientTest do
  use CatOnDuty.FixtureCase, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  alias CatOnDuty.BusinessCalendar.Client

  setup_all context do
    Finch.start_link(name: CatOnDuty.HTTP)

    {expected_calendar_document, []} =
      "external_calendar_2023.xml" |> context.file_fixture.() |> :erlang.binary_to_list() |> :xmerl_scan.string()

    {:ok, expected_calendar_document: expected_calendar_document}
  end

  test "when calendar was found", context do
    use_cassette "xml_calendar_200" do
      year = 2023
      assert Client.fetch(year) == {:ok, context.expected_calendar_document}
    end
  end

  test "when calendar was not found" do
    use_cassette "xml_calendar_404" do
      year = 1999
      assert Client.fetch(year) == {:error, :not_found}
    end
  end
end
