defmodule NycHousing.Store do
  use GenServer
  alias NycHousing.{Repo, Project, Neighborhood, Borough}

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
  def init(:ok), do: {:ok, initialize_state()}

  def handle_call({:get_project, id}, _from, state),
    do: {:reply, Enum.find(state.projects, &(&1.id == id)), state}

  def handle_call(:list_projects, _from, state),
    do: {:reply, state.projects, state}

  def handle_call({:get_neighborhood, id}, _from, state),
    do: {:reply, Enum.find(state.neighborhoods, &(&1.id == id)), state}

  def handle_call(:list_neighborhoods, _from, state),
    do: {:reply, state.neighborhoods, state}

  def handle_call({:get_borough, id}, _from, state),
    do: {:reply, Enum.find(state.boroughs, &(&1.id == id)), state}

  def handle_call(:list_boroughs, _from, state),
    do: {:reply, state.boroughs, state}

  def handle_call(:refresh, _from, _state), do: {:reply, :ok, initialize_state()}

  defp initialize_state do
    %{
      projects: Repo.all(Project),
      neighborhoods: Repo.all(Neighborhood),
      boroughs: Repo.all(Borough)
    }
  end
end
