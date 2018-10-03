defmodule NycHousing.ExternalData.LotteryApi.Lookup do
  use HTTPoison.Base

  @base "https://a806-housingconnect.nyc.gov/nyclottery/LttryLookup/LookupValues"

  @expected_fields ~w(
    LttryLookupSeqNo
    ShortName
    LongName
    SortOrder
    lookupName
  )

  @lookup_params %{
    "neighborhood" => "Neighborhood-",
    "borough" => "Boro"
  }

  @impl true
  def process_url(field),
    do: @base <> "?name=" <> Map.fetch!(@lookup_params, field)

  @impl true
  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Map.get("Result")
    |> List.first()
    |> process_result()
  end

  @spec process_result([map()]) :: [map()]
  defp process_result(result) when is_list(result),
    do: Enum.map(result, &process_result/1)

  @spec process_result(map()) :: map()
  defp process_result(result) when is_map(result) do
    result
    |> Map.take(@expected_fields)
    |> Enum.into(%{}, &(&1 |> process_k()))
  end

  @spec process_k({binary(), term()}) :: {atom, term()}
  defp process_k({k, v}), do: {k |> Recase.to_snake() |> String.to_atom(), v}
end
