defmodule NycHousing.Neighborhood do
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

  def lottery_changeset(lottery_result) when is_map(lottery_result) do
    params = %{
      external_id: lottery_result.lttry_lookup_seq_no,
      name: lottery_result.long_name,
      short_name: lottery_result.short_name,
      sort_order: lottery_result.sort_order
    }

    %Neighborhood{}
    |> cast(params, [
      :external_id,
      :name,
      :short_name,
      :sort_order
    ])
  end

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
