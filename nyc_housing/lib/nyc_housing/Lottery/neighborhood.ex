defmodule NycHousing.Lottery.Neighborhood do
  alias __MODULE__

  defstruct [:id, :name, :short_name, :sort_order]

  def from_api_result(result) do
    %Neighborhood{
      id: result.lttry_lookup_seq_no,
      name: result.long_name,
      short_name: result.short_name,
      sort_order: result.sort_order
    }
  end
end
