defmodule NycHousing.Consumers.NycOpenDataConsumer do
  use Task

  alias NycHousing.Consumers.Log
  alias NycHousing.{Store, Repo, Neighborhood}
  alias NycHousing.ExternalData.NycOpenDataApi

  def start_link(_), do: Task.start_link(__MODULE__, :run, [])

  def run do
    case Log.nyc_open_data_neighborhoods_last_polled() do
      nil ->
        with :ok <- poll_neighborhoods(),
             do: Log.log_nyc_open_data_neighborhoods()

      %DateTime{} ->
        :ok
    end
  end

  # Neighborhoods
  @spec poll_neighborhoods() :: :ok
  defp poll_neighborhoods do
    neighborhoods = Store.list_neighborhoods()
    api_neighborhoods = NycOpenDataApi.list_neighborhoods!()
    updated_neighborhoods = sync_api_neighborhoods(neighborhoods, api_neighborhoods)

    with :ok <- Store.refresh_neighborhoods(), do: {:ok, updated_neighborhoods}
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
