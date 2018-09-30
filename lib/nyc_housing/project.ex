defmodule NycHousing.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "project" do
    field(:external_id, :integer)
    field(:name, :string)
    field(:neighborhood_id, :integer)
    field(:borough_id, :integer)
    field(:addresses, {:array, :string})
    field(:published_date, :date)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:withdrawn?, :boolean)
    field(:deleted_date, :date)

    timestamps()
  end

  def lottery_changeset(lottery_result) when is_map(lottery_result) do
    params = %{
      external_id: lottery_result.lttry_proj_seq_no,
      name: lottery_result.project_name,
      neighborhood_id: lottery_result.neighborhood_lkp,
      borough_id: lottery_result.boro_lkp,
      addresses: lottery_result.addresses,
      published_date: lottery_result.published_date,
      start_date: lottery_result.app_start_dt,
      end_date: lottery_result.app_end_dt,
      withdrawn?: lottery_result.withdrawn
    }

    %Project{}
    |> cast(params, [
      :external_id,
      :name,
      :neighborhood_id,
      :borough_id,
      :addresses,
      :start_date,
      :end_date,
      :published_date,
      :withdrawn?
    ])
  end

  def lottery_changeset(%Project{} = project, lottery_result) when is_map(lottery_result) do
    params = %{
      name: lottery_result.project_name,
      neighborhood_id: lottery_result.neighborhood_lkp,
      borough_id_id: lottery_result.boro_lkp,
      addresses: lottery_result.addresses,
      published_date: lottery_result.published_date,
      start_date: lottery_result.app_start_dt,
      end_date: lottery_result.app_end_dt,
      withdrawn?: lottery_result.withdrawn
    }

    project
    |> cast(params, [
      :name,
      :boroughId_id,
      :neighborhood_id,
      :addresses,
      :published_date,
      :start_date,
      :end_date,
      :withdrawn?
    ])
  end

  def deleted_changeset(%Project{} = project) do
    project
    |> cast(%{deleted_date: Timex.today()}, [:deleted_date])
  end
end
