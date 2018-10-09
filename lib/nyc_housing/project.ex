defmodule NycHousing.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "project" do
    field :name, :string
    field :neighborhood_id, :integer
    field :borough_id, :integer
    field :addresses, {:array, :string}
    field :published_date, :date
    field :start_date, :date
    field :end_date, :date
    field :deleted_date, :date
    field :lottery_id, :integer

    timestamps()
  end

  def lottery_changeset(lottery_result) when is_map(lottery_result) do
    params = %{
      name: lottery_result.project_name,
      neighborhood_id: lottery_result.neighborhood_id,
      borough_id: lottery_result.borough_id,
      addresses: lottery_result.addresses,
      published_date: lottery_result.published_date,
      start_date: lottery_result.app_start_dt,
      end_date: lottery_result.app_end_dt,
      lottery_id: lottery_result.lttry_proj_seq_no
    }

    %Project{}
    |> cast(params, [
      :name,
      :neighborhood_id,
      :borough_id,
      :addresses,
      :start_date,
      :end_date,
      :published_date,
      :lottery_id
    ])
  end

  def lottery_changeset(%Project{} = project, lottery_result) when is_map(lottery_result) do
    params = %{
      name: lottery_result.project_name,
      addresses: lottery_result.addresses,
      start_date: lottery_result.app_start_dt,
      end_date: lottery_result.app_end_dt
    }

    project
    |> cast(params, [
      :name,
      :addresses,
      :start_date,
      :end_date
    ])
  end

  def deleted_changeset(%Project{} = project) do
    project
    |> cast(%{deleted_date: Timex.today()}, [:deleted_date])
  end
end
