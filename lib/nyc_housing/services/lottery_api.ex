defmodule NycHousing.Services.LotteryApi do
  alias __MODULE__.{Project, Lookup}

  @single_project "/GetProject?ProjNo="
  @multiple_projects "/GetPublishedCurrentUpcomingProjects"

  @spec list_projects() :: {:ok, [map()]} | {:error, %HTTPoison.Error{}}
  def list_projects do
    with {:ok, %{body: projects}} <- Project.get(@multiple_projects),
         do: {:ok, projects}
  end

  @spec list_projects!() :: [map()]
  def list_projects!, do: Project.get!(@multiple_projects).body

  @spec get_project(integer) :: {:ok, map()} | {:error, %HTTPoison.Error{}}
  def get_project(id) when is_integer(id) do
    with {:ok, %{body: project}} <- Project.get("#{@single_project}#{id}"),
         do: {:ok, project}
  end

  @spec get_project!(integer) :: map()
  def get_project!(id) when is_integer(id), do: Project.get!("#{@single_project}#{id}").body

  @spec list_neighborhoods() :: {:ok, [map()]} | {:error, %HTTPoison.Error{}}
  def list_neighborhoods do
    with {:ok, %{body: neighborhoods}} <- Lookup.get("neighborhood"),
         do: {:ok, neighborhoods}
  end

  @spec list_neighborhoods!() :: [map()]
  def list_neighborhoods!, do: Lookup.get!("neighborhood").body

  @spec list_boroughs() :: {:ok, [map()]} | {:error, %HTTPoison.Error{}}
  def list_boroughs do
    with {:ok, %{body: boroughs}} <- Lookup.get("borough"),
         do: {:ok, boroughs}
  end

  @spec list_boroughs!() :: [map()]
  def list_boroughs!, do: Lookup.get!("borough").body
end
