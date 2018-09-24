defmodule NycHousing.Lottery.Api.Project do
  use HTTPoison.Base
  alias NycHousing.Lottery.Project

  @base "https://a806-housingconnect.nyc.gov/nyclottery/LttryProject"

  @expected_fields ~w(
    LttryProjSeqNo
    ProjectName
    NeighborhoodLkp
    AppStartDt
    AppEndDt
    PublishedDate
    Published
    Withdrawn
    MapLink
  )

  @mdy_fields [:app_start_dt, :app_end_dt]
  @epoch_fields [:published_date]

  def process_url(url), do: @base <> url

  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Map.get("Result")
    |> process_result()
  end

  defp process_result(result) when is_map(result) do
    result
    |> Map.take(@expected_fields)
    |> Enum.into(%{}, &(&1 |> process_k() |> process_kv()))

    # |> map_project()
  end

  defp process_result(result) when is_list(result) do
    Enum.map(result, &process_result/1)
  end

  defp process_result(result), do: result
  defp process_k({k, v}), do: {k |> Recase.to_snake() |> String.to_atom(), v}

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
  defp process_addresses(nil), do: nil

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

  defp to_title(x) do
    x
    |> Recase.to_pascal()
    |> Recase.to_path()
    |> String.replace("/", " ")
  end

  defp process_mdy(nil), do: nil

  defp process_mdy(string) do
    string
    |> Timex.parse!("{M}/{D}/{YYYY}")
    |> Timex.to_datetime()
  end

  defp process_epoch(nil), do: nil

  defp process_epoch(string) do
    ~r|/Date\((?<epoch>\d+)\d{3}\)/|
    |> Regex.named_captures(string)
    |> Map.fetch!("epoch")
    |> Integer.parse(10)
    |> elem(0)
    |> Timex.from_unix()
  end

  defp map_project(result) do
    %Project{
      id: result.lttry_proj_seq_no,
      name: result.project_name,
      neighborhood_id: result.neighborhood_lkp,
      addresses: result.addresses,
      start_date: result.app_start_dt,
      end_date: result.app_end_dt,
      published?: result.published,
      published_date: result.published_date,
      withdrawn?: result.withdrawn
    }
  end
end
