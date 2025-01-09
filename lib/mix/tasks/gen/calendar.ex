defmodule Mix.Tasks.Gen.Calendar do
  @moduledoc false
  use Mix.Task

  alias CatOnDuty.BusinessCalendar

  @requirements ["app.start"]

  @default_dir_path "priv/business_calendars"

  @impl Mix.Task
  def run([year]) do
    run([year, @default_dir_path])
  end

  def run([year, dir_path | _]) do
    info =
      case BusinessCalendar.fetch(year) do
        {:ok, xml_document} ->
          xml_document
          |> BusinessCalendar.parse_from_xml()
          |> save(year, dir_path)

          "Календарь сгенерирован"

        {:error, :not_found} ->
          "Календарь на #{year} год отсутствует"

        _ ->
          "Ошибка"
      end

    Mix.shell().info(info)
  end

  defp save(calendar, year, dir_path) do
    json = JSON.encode!(calendar)

    [dir_path, "#{year}.json"]
    |> Path.join()
    |> File.write!(json)
  end
end
