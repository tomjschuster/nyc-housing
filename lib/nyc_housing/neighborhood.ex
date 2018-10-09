defmodule NycHousing.Neighborhood do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "neighborhood" do
    field :name, :string
    field :short_name, :string
    field :sort_order, :integer
    field :location, Geo.PostGIS.Geometry
    field :nyc_open_data_id, :integer
    field :lottery_id, :integer

    timestamps()
  end

  def lottery_changeset(api_result) when is_map(api_result) do
    params = %{
      name: api_result.long_name,
      short_name: api_result.short_name,
      sort_order: api_result.sort_order,
      lottery_id: api_result.lttry_lookup_seq_no
    }

    %Neighborhood{}
    |> cast(params, [
      :name,
      :short_name,
      :sort_order,
      :lottery_id
    ])
  end

  def lottery_changeset(nil, api_result) when is_map(api_result),
    do: lottery_changeset(api_result)

  def lottery_changeset(%Neighborhood{} = neighborhood, api_result)
      when is_map(api_result) do
    params = %{
      name: api_result.long_name,
      short_name: api_result.short_name,
      sort_order: api_result.sort_order
    }

    neighborhood
    |> cast(params, [
      :name,
      :short_name,
      :sort_order
    ])
  end

  def nyc_open_data_changeset(%{coordinates: coordinates} = api_result) when is_map(api_result) do
    params = %{
      name: api_result.name,
      location: %Geo.Point{coordinates: {coordinates.lat, coordinates.lng}},
      nyc_open_data_id: api_result.object_id
    }

    %Neighborhood{}
    |> cast(params, [
      :name,
      :location,
      :nyc_open_data_id
    ])
  end

  def nyc_open_data_changeset(nil, api_result) when is_map(api_result),
    do: nyc_open_data_changeset(api_result)

  def nyc_open_data_changeset(
        %Neighborhood{} = neighborhood,
        %{coordinates: coordinates} = api_result
      )
      when is_map(api_result) do
    params = %{
      name: api_result.name,
      location: %Geo.Point{coordinates: {coordinates.lat, coordinates.lng}}
    }

    neighborhood
    |> cast(params, [
      :name,
      :location
    ])
  end
end
