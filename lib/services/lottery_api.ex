defmodule Services.LotteryApi do
  alias __MODULE__.{Project, Lookup}

  @single_project "/GetProject?ProjNo="
  @multiple_projects "/GetPublishedCurrentUpcomingProjects"

  def list_projects do
    with {:ok, %{body: projects}} <- Project.get(@multiple_projects),
         do: {:ok, projects}
  end

  def list_projects!, do: Project.get!(@multiple_projects).body

  def get_project(id) when is_integer(id) do
    with {:ok, %{body: project}} <- Project.get("#{@single_project}#{id}"),
         do: {:ok, project}
  end

  def get_project!(id) when is_integer(id), do: Project.get!("#{@single_project}#{id}").body

  def list_neighborhoods do
    with {:ok, %{body: neighborhoods}} <- Lookup.get(:neighborhood),
         do: {:ok, neighborhoods}
  end

  def list_neighborhoods!, do: Lookup.get!(:neighborhood).body

  def list_boroughs do
    with {:ok, %{body: boroughs}} <- Lookup.get(:borough),
         do: {:ok, boroughs}
  end

  def list_boroughs!, do: Lookup.get!(:borough).body
end
