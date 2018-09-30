defmodule NycHousing.Lottery do
  alias NycHousing.{Lottery, Repo}
  alias Services.LotteryApi

  def synchronize do
    neighborhood_by_external_id = get_neighborhood_by_external_id()
    insert_update_api_neighborhoods(neighborhood_by_external_id)

    borough_by_external_id = get_borough_by_external_id()
    insert_update_api_boroughs(borough_by_external_id)

    project_by_external_id = get_project_by_external_id()

    project_by_external_id
    |> insert_update_api_projects(borough_by_external_id, neighborhood_by_external_id)
    |> update_deleted_projects(project_by_external_id)

    Lottery.Store.refresh()
  end

  defp get_neighborhood_by_external_id,
    do: Lottery.Neighborhood |> Repo.all() |> Enum.into(%{}, &{&1.external_id, &1})

  defp get_borough_by_external_id,
    do: Lottery.Borough |> Repo.all() |> Enum.into(%{}, &{&1.external_id, &1})

  defp get_project_by_external_id,
    do: Lottery.Project |> Repo.all() |> Enum.into(%{}, &{&1.external_id, &1})

  defp insert_update_api_neighborhoods(neighborhood_by_external_id) do
    LotteryApi.list_neighborhoods!()
    |> Enum.map(fn %{lttry_lookup_seq_no: external_id} = api_neighborhood ->
      case neighborhood_by_external_id do
        %{^external_id => neighborhood} ->
          neighborhood
          |> Lottery.Neighborhood.api_changeset(api_neighborhood)
          |> Repo.update!()

        %{} ->
          api_neighborhood
          |> Lottery.Neighborhood.api_changeset()
          |> Repo.insert!()
      end
    end)
  end

  defp insert_update_api_boroughs(borough_by_external_id) do
    LotteryApi.list_boroughs!()
    |> Enum.map(fn %{lttry_lookup_seq_no: external_id} = api_borough ->
      case borough_by_external_id do
        %{^external_id => borough} ->
          borough
          |> Lottery.Borough.api_changeset(api_borough)
          |> Repo.update!()

        %{} ->
          api_borough
          |> Lottery.Borough.api_changeset()
          |> Repo.insert!()
      end
    end)
  end

  defp insert_update_api_projects(
         project_by_external_id,
         neighborhood_by_external_id,
         borough_by_external_id
       ) do
    LotteryApi.list_projects!()
    |> Stream.map(fn %{
                       neighborhood_lkp: neighborhood_external_id,
                       boro_lkp: borough_external_id
                     } = api_project ->
      neighborhood = Map.get(neighborhood_by_external_id, neighborhood_external_id)
      borough = Map.get(borough_by_external_id, borough_external_id)

      api_project
      |> Map.put(:neighborhood_id, neighborhood && neighborhood.id)
      |> Map.put(:borough_id, borough && borough.id)
    end)
    |> Enum.map(fn %{lttry_proj_seq_no: external_id} = api_project ->
      case project_by_external_id do
        %{^external_id => project} ->
          project
          |> Lottery.Project.api_changeset(api_project)
          |> Repo.update!()

        %{} ->
          api_project
          |> Lottery.Project.api_changeset()
          |> Repo.insert!()
      end
    end)
  end

  defp update_deleted_projects(api_projects, project_by_external_id) do
    api_project_by_external_id = Enum.into(api_projects, %{}, &{&1.external_id, &1})

    project_by_external_id
    |> Stream.map(&elem(&1, 1))
    |> Stream.filter(&(not Map.has_key?(api_project_by_external_id, &1.external_id)))
    |> Stream.map(&Lottery.Project.deleted_changeset/1)
    |> Stream.each(&Repo.update!/1)
    |> Stream.run()
  end
end
