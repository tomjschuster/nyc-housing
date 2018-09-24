defmodule NycHousing.Lottery do
  alias NycHousing.Repo
  alias NycHousing.Lottery.{Api, Project}

  def synchronize do
    project_by_external_id =
      Project
      |> Repo.all()
      |> Enum.into(%{}, &{&1.external_id, &1})

    Api.list_projects!()
    |> Enum.each(fn %{lttry_proj_seq_no: external_id} = api_project ->
      case project_by_external_id do
        %{^external_id => project} ->
          project
          |> Project.api_changeset(api_project)
          |> Repo.update!()

        %{} ->
          api_project
          |> Project.api_changeset()
          |> Repo.insert!()
      end
    end)
  end
end
