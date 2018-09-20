defmodule NycHousing.Lottery.Project do
  alias __MODULE__

  defstruct [
    :id,
    :name,
    :neighborhood,
    :addresses,
    :start_date,
    :end_date,
    :published?,
    :published_date,
    :withdrawn?,
    :deleted?,
    :deleted_date
  ]

  def from_api_result(result, neighborhood_by_id) do
    %Project{
      id: result.lttry_proj_seq_no,
      name: result.project_name,
      neighborhood: Map.get(neighborhood_by_id, result.neighborhood_lkp),
      addresses: result.addresses,
      start_date: result.app_start_dt,
      end_date: result.app_end_dt,
      published?: result.published,
      published_date: result.published_date,
      withdrawn?: result.withdrawn
    }
  end
end
