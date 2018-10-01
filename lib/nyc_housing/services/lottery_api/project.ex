defmodule NycHousing.Services.LotteryApi.Project do
  use HTTPoison.Base

  @base "https://a806-housingconnect.nyc.gov/nyclottery/LttryProject"

  @expected_fields ~w(
    LttryProjSeqNo
    ProjectName
    NeighborhoodLkp
    BoroLkp
    AppStartDt
    AppEndDt
    PublishedDate
    Published
    Withdrawn
    MapLink
  )

  @mdy_fields [:app_start_dt, :app_end_dt]
  @epoch_fields [:published_date]

  @impl true
  def process_url(url), do: @base <> url

  @impl true
  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Map.get("Result")
    |> process_result()
  end

  @spec process_result(term()) :: term()
  defp process_result(result)

  defp process_result(result) when is_map(result) do
    result
    |> Map.take(@expected_fields)
    |> Enum.into(%{}, &(&1 |> process_k() |> process_kv()))
  end

  defp process_result(result) when is_list(result) do
    Enum.map(result, &process_result/1)
  end

  defp process_result(result), do: result

  @spec process_k({binary(), term()}) :: {atom(), term()}
  defp process_k({k, v}), do: {k |> Recase.to_snake() |> String.to_atom(), v}

  @spec process_kv({atom(), term()}) :: {atom(), term()}
  defp process_kv(kv)

  defp process_kv({k, v}) when k in @mdy_fields, do: {k, process_mdy(v)}

  defp process_kv({k, v}) when k in @epoch_fields, do: {k, process_epoch(v)}

  defp process_kv({:map_link, url}) do
    addresses =
      url
      |> String.split("s=")
      |> Enum.at(1)
      |> process_addresses()

    {:addresses, addresses}
  end

  defp process_kv({k, v}), do: {k, v}

  @spec process_addresses(nil) :: []
  defp process_addresses(nil), do: []

  @spec process_addresses(binary()) :: [binary()]
  defp process_addresses(string) do
    string
    |> String.replace("a:", "")
    |> String.split(";")
    |> Enum.map(fn string ->
      [number, street, borough] =
        string
        |> String.split(",")
        |> Enum.map(fn x ->
          x
          |> String.split("+")
          |> Enum.map(&to_title/1)
          |> Enum.join(" ")
        end)

      "#{number} #{street}, #{borough}, NY"
    end)
  end

  @spec to_title(binary()) :: binary()
  defp to_title(x) do
    x
    |> Recase.to_pascal()
    |> Recase.to_path()
    |> String.replace("/", " ")
  end

  @spec process_mdy(nil) :: nil
  defp process_mdy(nil), do: nil

  @spec process_mdy(binary()) :: %DateTime{}
  defp process_mdy(string) do
    string
    |> Timex.parse!("{M}/{D}/{YYYY}")
    |> Timex.to_datetime()
  end

  @spec process_epoch(nil) :: nil
  defp process_epoch(nil), do: nil

  @spec process_epoch(binary) :: %DateTime{}
  defp process_epoch(string) do
    ~r|/Date\((?<epoch>\d+)\d{3}\)/|
    |> Regex.named_captures(string)
    |> Map.fetch!("epoch")
    |> Integer.parse(10)
    |> elem(0)
    |> Timex.from_unix()
  end
end
