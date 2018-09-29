defmodule NycHousing.Lottery.Store do
  use GenServer
  alias NycHousing.Repo
  alias NycHousing.Lottery.{Project, Neighborhood, Borough}

  # Client
  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_project(id), do: GenServer.call(__MODULE__, {:get_project, id})
  def list_projects, do: GenServer.call(__MODULE__, :list_projects)
  def get_neighborhood(id), do: GenServer.call(__MODULE__, {:get_neighborhood, id})
  def list_neighborhoods, do: GenServer.call(__MODULE__, :list_neighborhoods)
  def get_borough(id), do: GenServer.call(__MODULE__, {:get_borough, id})
  def list_boroughs, do: GenServer.call(__MODULE__, :list_boroughs)
  def refresh, do: GenServer.call(__MODULE__, :refresh)

  # Server
  def init(:ok) do
    state = %{
      projects: Repo.all(Project),
      neighborhoods: Repo.all(Neighborhood),
      boroughs: Repo.all(Borough)
    }

    {:ok, state}
  end

  def handle_call({:get_project, id}, _from, state) do
    project =
      state.projects
      |> Enum.filter(&(&1.id == id))
      |> List.first()

    {:reply, project, state}
  end

  def handle_call(:list_projects, _from, state),
    do: {:reply, state.projects, state}

  def handle_call({:get_neighborhood, id}, _from, state) do
    neighborhood =
      state.neighborhoods
      |> Enum.filter(&(&1.id == id))
      |> List.first()

    {:reply, neighborhood, state}
  end

  def handle_call(:list_neighborhoods, _from, state),
    do: {:reply, state.neighborhoods, state}

  def handle_call({:get_borough, id}, _from, state) do
    borough =
      state.boroughs
      |> Enum.filter(&(&1.id == id))
      |> List.first()

    {:reply, borough, state}
  end

  def handle_call(:list_boroughs, _from, state),
    do: {:reply, state.boroughs, state}

  def handle_call(:refresh, _from, _state) do
    projects = Repo.all(Project)
    neighborhoods = Repo.all(Neighborhood)
    {:reply, :ok, %{projects: projects, neighborhoods: neighborhoods}}
  end
end
