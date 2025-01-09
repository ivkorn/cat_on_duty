defmodule CatOnDuty.BusinessCalendar.ParserTest do
  use CatOnDuty.FixtureCase, async: true

  alias CatOnDuty.BusinessCalendar.Parser

  @types ["working", "day off"]

  setup_all context do
    {xml_calendar, []} =
      "external_calendar_2023.xml" |> context.file_fixture.() |> :erlang.binary_to_list() |> :xmerl_scan.string()

    json_calendar = context.file_fixture.("parsed_calendar_2023.json")

    {:ok, xml_calendar: xml_calendar, json_calendar: json_calendar}
  end

  test "parse xml_calendar", context do
    result = Parser.parse_from_xml(context.xml_calendar)

    Enum.each(result, fn {date, type} ->
      assert is_binary(date)
      assert Enum.member?(@types, type)
    end)
  end

  test "parse json_calendar", context do
    result = Parser.parse_from_json(context.json_calendar)

    Enum.each(result, fn {date, type} ->
      assert is_struct(date, Date)
      assert Enum.member?(@types, type)
    end)
  end
end
