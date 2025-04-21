defmodule CatOnDuty.BusinessCalendar.Client do
  @moduledoc false
  @headers [{"accept", "text/xml"}]
  def fetch(year) do
    response_result = :get |> Finch.build(url(year), @headers) |> Finch.request(CatOnDuty.HTTP)

    case response_result do
      {:ok, %{status: 200, body: body}} -> {:ok, to_xml(body)}
      {:ok, %{status: 404}} -> {:error, :not_found}
      _any -> {:error, :unknown_error}
    end
  end

  defp url(year) do
    "https://xmlcalendar.ru/data/ru/#{year}/calendar.xml"
  end

  defp to_xml(body) do
    {document, []} = body |> :erlang.binary_to_list() |> :xmerl_scan.string()
    document
  end
end
