defmodule NycHousing.Store do
  use GenServer

  alias NycHousing.{Repo, Project, Neighborhood, Borough}

  @type state :: map()

  # Client
  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## Projects28
  def get_project(id), do: GenServer.call(__MODULE__, {:get_project, id})

  def get_project_by_lottery_id(lottery_id),
    do: GenServer.call(__MODULE__, {:get_project_by_lottery_id, lottery_id})

  def list_projects, do: GenServer.call(__MODULE__, :list_projects)

  def refresh_projects, do: GenServer.call(__MODULE__, :refresh_projects)

  ## Neighborhoods
  def get_neighborhood(id), do: GenServer.call(__MODULE__, {:get_neighborhood, id})

  def get_neighborhood_by_lottery_id(lottery_id),
    do: GenServer.call(__MODULE__, {:get_neighborhood_by_lottery_id, lottery_id})

  def list_neighborhoods, do: GenServer.call(__MODULE__, :list_neighborhoods)

  def refresh_neighborhoods, do: GenServer.call(__MODULE__, :refresh_neighborhoods)

  ## Boroughs
  def get_borough(id), do: GenServer.call(__MODULE__, {:get_borough, id})

  def get_borough_by_lottery_id(lottery_id),
    do: GenServer.call(__MODULE__, {:get_borough_by_lottery_id, lottery_id})

  def list_boroughs, do: GenServer.call(__MODULE__, :list_boroughs)

  def refresh_boroughs, do: GenServer.call(__MODULE__, :refresh_boroughs)

  # Server
  @impl true
  def init(:ok) do
    state =
      %{}
      |> initialize_projects()
      |> initialize_neighborhoods()
      |> initialize_boroughs()

    {:ok, state}
  end

  ## Projects
  @impl true
  def handle_call({:get_project, id}, _from, state),
    do: {:reply, Map.get(state.projects, id), state}

  @impl true
  def handle_call({:get_project_by_lottery_id, lottery_id}, _from, state),
    do: {:reply, Map.get(state.projects_by_lottery_id, lottery_id), state}

  @impl true
  def handle_call(:list_projects, _from, state) do
    projects =
      state.projects
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort_by(& &1.end_date)

    {:reply, projects, state}
  end

  @impl true
  def handle_call(:refresh_projects, _from, state),
    do: {:reply, :ok, initialize_projects(state)}

  ## Neighborhoods
  @impl true
  def handle_call({:get_neighborhood, id}, _from, state),
    do: {:reply, Map.get(state.neighborhoods, id), state}

  @impl true
  def handle_call({:get_neighborhood_by_lottery_id, lottery_id}, _from, state),
    do: {:reply, Map.get(state.neighborhoods_by_lottery_id, lottery_id), state}

  @impl true
  def handle_call(:list_neighborhoods, _from, state) do
    neighborhoods =
      state.neighborhoods
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort_by(& &1.sort_order)

    {:reply, neighborhoods, state}
  end

  @impl true
  def handle_call(:refresh_neighborhoods, _from, state),
    do: {:reply, :ok, initialize_neighborhoods(state)}

  ## Boroughs
  @impl true
  def handle_call({:get_borough, id}, _from, state),
    do: {:reply, Map.get(state.boroughs, id), state}

  @impl true
  def handle_call({:get_borough_by_lottery_id, lottery_id}, _from, state),
    do: {:reply, Map.get(state.boroughs_by_lottery_id, lottery_id), state}

  @impl true
  def handle_call(:list_boroughs, _from, state) do
    boroughs =
      state.boroughs
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort_by(& &1.sort_order)

    {:reply, boroughs, state}
  end

  @impl true
  def handle_call(:refresh_boroughs, _from, state),
    do: {:reply, :ok, initialize_boroughs(state)}

  # Helpers
  @spec initialize_projects(state) :: state
  defp initialize_projects(state) do
    projects = Repo.all(Project)

    state
    |> Map.put(:projects, Enum.into(projects, %{}, &{&1.id, &1}))
    |> Map.put(:projects_by_lottery_id, Enum.into(projects, %{}, &{&1.lottery_id, &1}))
  end

  @spec initialize_neighborhoods(state) :: state
  defp initialize_neighborhoods(state) do
    neighborhoods = Repo.all(Neighborhood)

    state
    |> Map.put(:neighborhoods, Enum.into(neighborhoods, %{}, &{&1.id, &1}))
    |> Map.put(:neighborhoods_by_lottery_id, Enum.into(neighborhoods, %{}, &{&1.lottery_id, &1}))
  end

  @spec initialize_boroughs(state) :: state
  defp initialize_boroughs(state) do
    boroughs = Repo.all(Borough)

    state
    |> Map.put(:boroughs, Enum.into(boroughs, %{}, &{&1.id, &1}))
    |> Map.put(:boroughs_by_lottery_id, Enum.into(boroughs, %{}, &{&1.lottery_id, &1}))
  end
end
