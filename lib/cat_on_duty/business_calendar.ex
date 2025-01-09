defmodule CatOnDuty.BusinessCalendar do
  @moduledoc """
    Module that's contains not business days
  """
  alias CatOnDuty.BusinessCalendar.Client
  alias CatOnDuty.BusinessCalendar.Parser

  @business_calendar "priv/business_calendars/*.json"
                     |> Path.wildcard()
                     |> Stream.each(&(@external_resource Path.relative_to_cwd(&1)))
                     |> Stream.map(&File.read!/1)
                     |> Stream.map(&Parser.parse_from_json/1)
                     |> Enum.reduce(fn calendar, calendars -> Map.merge(calendar, calendars) end)

  defguardp is_calendarable(term)
            when is_struct(term, NaiveDateTime) or is_struct(term, DateTime) or is_struct(term, Date)

  defdelegate fetch(term), to: Client
  defdelegate parse_from_xml(term), to: Parser

  @spec calendar() :: %{Date.t() => String.t()}
  def calendar do
    @business_calendar
  end

  @spec working_day?(Date.t() | DateTime.t() | NaiveDateTime.t()) :: boolean()
  def working_day?(date_or_datetime) when is_calendarable(date_or_datetime) do
    date_or_datetime
    |> to_date()
    |> then(&@business_calendar[&1])
    |> working?()
  end

  defp working?("working"), do: true
  defp working?("day off"), do: false
  defp working?(nil), do: true

  defp to_date(%NaiveDateTime{} = datetime), do: NaiveDateTime.to_date(datetime)
  defp to_date(%DateTime{} = datetime), do: DateTime.to_date(datetime)
  defp to_date(%Date{} = date), do: date
end
