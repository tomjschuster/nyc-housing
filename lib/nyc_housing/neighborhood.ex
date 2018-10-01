defmodule NycHousing.Neighborhood do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "neighborhood" do
    field(:name, :string)
    field(:short_name, :string)
    field(:sort_order, :integer)
    field(:lottery_id, :integer)

    timestamps()
  end

  def lottery_changeset(lottery_result) when is_map(lottery_result) do
    params = %{
      name: lottery_result.long_name,
      short_name: lottery_result.short_name,
      sort_order: lottery_result.sort_order,
      lottery_id: lottery_result.lttry_lookup_seq_no
    }

    %Neighborhood{}
    |> cast(params, [
      :name,
      :short_name,
      :sort_order,
      :lottery_id
    ])
  end

  def lottery_changeset(nil, lottery_result) when is_map(lottery_result),
    do: lottery_changeset(lottery_result)

  def lottery_changeset(%Neighborhood{} = neighborhood, lottery_result)
      when is_map(lottery_result) do
    params = %{
      name: lottery_result.long_name,
      short_name: lottery_result.short_name,
      sort_order: lottery_result.sort_order
    }

    neighborhood
    |> cast(params, [
      :name,
      :short_name,
      :sort_order
    ])
  end
end
