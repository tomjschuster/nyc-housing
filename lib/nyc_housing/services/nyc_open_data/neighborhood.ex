# https://data.cityofnewyork.us/resource/xyye-rtrs.json

defmodule NycHousing.Services.NycOpenData.Neighborhood do
  use HTTPoison.Base

  @base "https://data.cityofnewyork.us/resource/xyye-rtrs.json"

  @expected_fields ~w(
    name
    objectid
    stacked
    the_geom
  )

  @impl true
  def process_url(""), do: @base
  def process_url(query), do: @base <> "?" <> URI.encode(query)

  @impl true
  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> process_result()
  end

  @spec process_result([map()]) :: [map()]
  defp process_result(result) when is_list(result),
    do: Enum.map(result, &process_result/1)

  @spec process_result(map()) :: map()
  defp process_result(result) when is_map(result) do
    result
    |> Map.take(@expected_fields)
    |> Enum.into(%{}, &process_kv/1)
  end

  @spec process_kv({binary(), term()}) :: {atom, term()}
  defp process_kv({"the_geom", v}), do: {:coordinates, process_coordinates(v)}
  defp process_kv({"objectid", v}), do: {:object_id, parse_int(v)}
  defp process_kv({"stacked", v}), do: {:stacked, parse_int(v)}
  defp process_kv({k, v}), do: {k |> Recase.to_snake() |> String.to_atom(), v}

  @spec process_coordinates(%{required(binary()) => [float()]}) :: %{
          lat: float(),
          lng: float()
        }
  defp process_coordinates(%{"coordinates" => [lng, lat]}), do: %{lat: lat, lng: lng}

  @spec parse_int(binary()) :: integer()
  defp parse_int(string) do
    {int, ""} = Integer.parse(string, 10)
    int
  end
end
