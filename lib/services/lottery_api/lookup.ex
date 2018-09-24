defmodule Services.LotteryApi.Lookup do
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
    "neighborhood" => "Neighborhood-"
  }

  def process_url(field),
    do: @base <> "?name=" <> Map.fetch!(@lookup_params, field)

  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Map.get("Result")
    |> List.first()
    |> process_result()
  end

  defp process_result(result) when is_list(result),
    do: Enum.map(result, &process_result/1)

  defp process_result(result) when is_map(result) do
    result
    |> Map.take(@expected_fields)
    |> Enum.into(%{}, &(&1 |> process_k()))

    # |> map_lookup()
  end

  defp process_k({k, v}), do: {k |> Recase.to_snake() |> String.to_atom(), v}

  # defp map_lookup(%{lookup_name: "Neighborhood-"} = result) do
  #   %Neighborhood{
  #     id: result.lttry_lookup_seq_no,
  #     name: result.long_name,
  #     short_name: result.short_name,
  #     sort_order: result.sort_order
  #   }
  # end
end
