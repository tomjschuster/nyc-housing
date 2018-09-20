defmodule NycHousing.Lottery.Store do
  use GenServer

  alias NycHousing.Lottery.{Neighborhood, Project}

  # Client
  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_project(id), do: GenServer.call(__MODULE__, {:get_project, id})
  def get_neighborhood(id), do: GenServer.call(__MODULE__, {:get_neighborhood, id})

  def list_projects, do: GenServer.call(__MODULE__, :list_projects)
  def list_neighborhoods, do: GenServer.call(__MODULE__, :list_neighborhoods)

  def init(:ok) do
    with {:ok, raw_projects} <- fetch_projects(),
         {:ok, raw_neighborhoods} = fetch_neighborhoods() do
      neighborhoods = Enum.map(raw_neighborhoods, &Neighborhood.from_api_result/1)
      neighborhood_by_id = Enum.into(neighborhoods, %{}, &{&1.id, &1})
      projects = Enum.map(raw_projects, &Project.from_api_result(&1, neighborhood_by_id))

      {:ok, %{projects: projects, neighborhoods: neighborhoods}}
    end
  end

  def handle_call({:get_project, id}, _from, state) do
    project =
      state.projects
      |> Enum.filter(&(&1.id == id))
      |> List.first()

    {:reply, project, state}
  end

  def handle_call({:get_neighborhood, id}, _from, state) do
    neighborhood =
      state.neighborhoods
      |> Enum.filter(&(&1.id == id))
      |> List.first()

    {:reply, neighborhood, state}
  end

  def handle_call(:list_projects, _from, state), do: {:reply, state.projects, state}
  def handle_call(:list_neighborhoods, _from, state), do: {:reply, state.neighborhoods, state}

  def handle_cast(:refresh, _state) do
    with {:ok, raw_projects} <- fetch_projects(),
         {:ok, raw_neighborhoods} = fetch_neighborhoods() do
      neighborhoods = Enum.map(raw_neighborhoods, &Neighborhood.from_api_result/1)
      neighborhood_by_id = Enum.into(neighborhoods, %{}, &{&1.id, &1})
      projects = Enum.map(raw_projects, &Project.from_api_result(&1, neighborhood_by_id))

      {:noreply, %{projects: projects, neighborhoods: neighborhoods}}
    end
  end

  defp fetch_projects, do: fetch_with_retry(&get_lottery_projects/0)
  defp fetch_neighborhoods, do: fetch_with_retry(&get_neighborhood_lookup/0)

  defp fetch_with_retry(f, retries_remaining \\ 5) do
    case {retries_remaining, f.()} do
      {1, {:error, %HTTPoison.Error{}} = error} ->
        {:error, error}

      {_, _error = %HTTPoison.Error{}} ->
        :timer.sleep(500)
        f.(retries_remaining - 1)

      {_, {:ok, neighborhoods}} ->
        {:ok, neighborhoods}
    end
  end

  @lottery_base "/LttryProject"
  @lookup_base "/LttryLookup/LookupValues"
  @neighborhood_lookup "Neighborhood-"

  defp get_lottery_projects do
    result = Data.NycLottery.get(@lottery_base <> "/GetPublishedCurrentUpcomingProjects")
    with {:ok, %{body: projects}} <- result, do: {:ok, projects}
  end

  defp get_neighborhood_lookup do
    result =
      [@neighborhood_lookup]
      |> lookup_url()
      |> Data.NycLottery.get()

    with {:ok, %{body: [neighborhoods]}} <- result, do: {:ok, neighborhoods}
  end

  defp lookup_url(fields) do
    fields_param = Enum.join(fields, "%7C")
    @lookup_base <> "?name=" <> fields_param
  end
end
