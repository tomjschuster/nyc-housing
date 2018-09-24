defmodule NycHousing.Lottery.Api do
  alias __MODULE__

  @single_project "/GetProject?ProjNo="
  @multiplie_projects "/GetPublishedCurrentUpcomingProjects"

  def list_projects do
    with {:ok, %{body: projects}} <- Api.Project.get(@multiplie_projects),
         do: {:ok, projects}
  end

  def get_project(id) when is_integer(id) do
    with {:ok, %{body: project}} <- Api.Project.get("#{@single_project}#{id}"),
         do: {:ok, project}
  end

  def list_neighborhoods do
    with {:ok, %{body: neighborhoods}} <- Api.Lookup.get(:neighborhood),
         do: {:ok, neighborhoods}
  end
end
