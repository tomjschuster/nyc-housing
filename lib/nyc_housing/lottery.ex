defmodule NycHousing.Lottery do
  alias NycHousing.Repo
  alias NycHousing.Lottery.{Api, Project}

  def synchronize do
    project_by_external_id = get_project_by_external_id()

    project_by_external_id
    |> insert_update_api_projects()
    |> update_deleted_projects(project_by_external_id)
  end

  defp get_project_by_external_id,
    do: Project |> Repo.all() |> Enum.into(%{}, &{&1.external_id, &1})

  defp insert_update_api_projects(project_by_external_id) do
    Api.list_projects!()
    |> Enum.map(fn %{lttry_proj_seq_no: external_id} = api_project ->
      case project_by_external_id do
        %{^external_id => project} ->
          project |> Project.api_changeset(api_project) |> Repo.update!()

        %{} ->
          api_project |> Project.api_changeset() |> Repo.insert!()
      end
    end)
  end

  defp update_deleted_projects(api_projects, project_by_external_id) do
    api_project_by_external_id = Enum.into(api_projects, %{}, &{&1.external_id, &1})

    project_by_external_id
    |> Stream.map(&elem(&1, 1))
    |> Stream.filter(&(not Map.has_key?(api_project_by_external_id, &1.external_id)))
    |> Stream.map(&Project.deleted_changeset/1)
    |> Stream.each(&Repo.update!/1)
    |> Stream.run()
  end
end
