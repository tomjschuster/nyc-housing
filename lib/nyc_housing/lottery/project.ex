defmodule NycHousing.Lottery.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "lottery_project" do
    field(:external_id, :integer)
    field(:name, :string)
    field(:neighborhood_id, :integer)
    field(:addresses, {:array, :string})
    field(:start_date, :date)
    field(:end_date, :date)
    field(:published?, :boolean)
    field(:published_date, :date)
    field(:withdrawn?, :boolean)
    field(:deleted_date, :date)

    timestamps()
  end

  def api_changeset(api_result) when is_map(api_result) do
    params = %{
      external_id: api_result.lttry_proj_seq_no,
      name: api_result.project_name,
      neighborhood_id: api_result.neighborhood_lkp,
      addresses: api_result.addresses,
      start_date: api_result.app_start_dt,
      end_date: api_result.app_end_dt,
      published?: api_result.published,
      published_date: api_result.published_date,
      withdrawn?: api_result.withdrawn
    }

    %Project{}
    |> cast(params, [
      :external_id,
      :name,
      :neighborhood_id,
      :addresses,
      :start_date,
      :end_date,
      :published?,
      :published_date,
      :withdrawn?
    ])
  end

  def api_changeset(%Project{} = project, api_result) when is_map(api_result) do
    params = %{
      name: api_result.project_name,
      neighborhood_id: api_result.neighborhood_lkp,
      addresses: api_result.addresses,
      start_date: api_result.app_start_dt,
      end_date: api_result.app_end_dt,
      published?: api_result.published,
      published_date: api_result.published_date,
      withdrawn?: api_result.withdrawn
    }

    project
    |> cast(params, [
      :name,
      :neighborhood_id,
      :addresses,
      :start_date,
      :end_date,
      :published?,
      :published_date,
      :withdrawn?
    ])
  end

  def deleted_changeset(%Project{} = project) do
    project
    |> cast(%{deleted_date: Timex.today()}, [:deleted_date])
  end
end
