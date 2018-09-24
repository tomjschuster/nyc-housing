defmodule NycHousing.Lottery.Neighborhood do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "neighborhood" do
    field(:external_id, :integer)
    field(:name, :string)
    field(:short_name, :string)
    field(:sort_order, :integer)

    timestamps()
  end

  def api_changeset(api_result) when is_map(api_result) do
    params = %{
      external_id: api_result.lttry_lookup_seq_no,
      name: api_result.long_name,
      short_name: api_result.short_name,
      sort_order: api_result.sort_order
    }

    %Neighborhood{}
    |> cast(params, [
      :external_id,
      :name,
      :short_name,
      :sort_order
    ])
  end

  def api_changeset(%Neighborhood{} = neighborhood, api_result) when is_map(api_result) do
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
end
