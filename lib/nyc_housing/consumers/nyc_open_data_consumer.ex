defmodule NycHousing.Consumers.NycOpenDataConsumer do
  use GenServer

  alias NycHousing.Consumers.Log
  alias NycHousing.{Store, Repo, Neighborhood}
  alias NycHousing.ExternalData.NycOpenDataApi

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    IO.puts("Initializing Nyc Open Data Consumer")

    case Log.nyc_open_data_neighborhoods_last_polled() do
      nil ->
        IO.puts("Polling NYC Open Data Neighborhoods")

        with :ok <- poll_neighborhoods(),
             IO.puts("NYC Open Data Neighborhoods Complete"),
             :ok <- Log.log_nyc_open_data_neighborhoods(),
             do: :ignore

      %DateTime{} ->
        :ignore
    end
  end

  # Neighborhoods
  @spec poll_neighborhoods() :: :ok
  defp poll_neighborhoods do
    neighborhoods = Store.list_neighborhoods()
    api_neighborhoods = NycOpenDataApi.list_neighborhoods!()
    sync_api_neighborhoods(neighborhoods, api_neighborhoods)
    Store.refresh_neighborhoods()
  end

  @spec sync_api_neighborhoods([%Neighborhood{}], [map()]) :: [%Neighborhood{}]
  defp sync_api_neighborhoods(neighborhoods, api_neighborhoods) do
    neighborhoods_by_api_id = Enum.into(neighborhoods, %{}, &{&1.nyc_open_data_id, &1})

    Enum.map(api_neighborhoods, fn api_neighborhood ->
      neighborhoods_by_api_id
      |> Map.get(api_neighborhood.object_id)
      |> Neighborhood.nyc_open_data_changeset(api_neighborhood)
      |> Repo.insert_or_update!()
    end)
  end
end
