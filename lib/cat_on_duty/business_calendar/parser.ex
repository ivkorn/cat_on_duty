defmodule CatOnDuty.BusinessCalendar.Parser do
  @moduledoc false
  require Record

  [from_lib: "xmerl/include/xmerl.hrl"]
  |> Record.extract_all()
  |> Enum.each(fn {key, value} ->
    # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
    name = key |> Atom.to_string() |> Macro.underscore() |> String.to_atom()
    Record.defrecord(name, key, value)
  end)

  @day_offs_xml_path ~c"/calendar/days/day[@t=\"1\"]"
  @shortened_working_days_xml_path ~c"/calendar/days/day[@t=\"2\"]"
  @working_days_xml_path ~c"/calendar/days/day[@t=\"3\"]"
  @regular_day_offs 6..7
  @day_off_type "day off"
  @working_type "working"

  def parse_from_json(json_string) do
    json_string |> JSON.decode!() |> Map.new(fn {key, value} -> {Date.from_iso8601!(key), value} end)
  end

  def parse_from_xml(xml_document) do
    year = extract_year(xml_document)
    day_off_dates = extract_day_off_dates(xml_document, year)
    working_dates = extract_working_dates(xml_document, year) ++ extract_shortened_working_dates(xml_document, year)

    year
    |> Date.new!(1, 1)
    |> Date.range(Date.new!(year, 12, 31))
    |> Map.new(&{Date.to_iso8601(&1), fetch_date_type(&1, working_dates, day_off_dates)})
  end

  defp extract_year(document) do
    document
    |> xml_element(:attributes)
    |> Enum.find(&(xml_attribute(&1, :name) == :year))
    |> xml_attribute(:value)
    |> :erlang.list_to_integer()
  end

  defp extract_day_off_dates(document, year) do
    @day_offs_xml_path |> extract_nodes(document) |> extract_dates(year)
  end

  defp extract_shortened_working_dates(document, year) do
    @shortened_working_days_xml_path |> extract_nodes(document) |> extract_dates(year)
  end

  defp extract_working_dates(document, year) do
    @working_days_xml_path |> extract_nodes(document) |> extract_dates(year)
  end

  defp extract_nodes(path, document) do
    :xmerl_xpath.string(path, document)
  end

  defp extract_dates(nodes, year) do
    Enum.map(nodes, fn node ->
      [month | [day]] =
        node
        |> xml_element(:attributes)
        |> Enum.find(&(xml_attribute(&1, :name) == :d))
        |> xml_attribute(:value)
        |> List.to_string()
        |> String.split(".")
        |> Enum.map(&String.to_integer/1)

      Date.new!(year, month, day)
    end)
  end

  defp fetch_date_type(date, working_dates, day_off_dates) do
    if working_date?(date, working_dates, day_off_dates) do
      @working_type
    else
      @day_off_type
    end
  end

  defp working_date?(date, working_dates, day_off_dates) do
    case Date.day_of_week(date) do
      day when day in @regular_day_offs -> Enum.member?(working_dates, date)
      _other -> !Enum.member?(day_off_dates, date)
    end
  end
end
