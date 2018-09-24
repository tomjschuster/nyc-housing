defmodule NycHousing.Lottery.Store do
  use GenServer
  alias NycHousing.Lottery.Api

  # Client
  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_project(id), do: GenServer.call(__MODULE__, {:get_project, id})
  def list_projects, do: GenServer.call(__MODULE__, :list_projects)
  def get_neighborhood(id), do: GenServer.call(__MODULE__, {:get_neighborhood, id})
  def list_neighborhoods, do: GenServer.call(__MODULE__, :list_neighborhoods)

  # Server
  def init(:ok) do
    with {:ok, projects} <- fetch_with_retry(&Api.list_projects/0),
         {:ok, neighborhoods} = fetch_with_retry(&Api.list_neighborhoods/0) do
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

  def handle_cast(:refresh, _state) do
    with {:ok, projects} <- fetch_with_retry(&Api.list_projects/0),
         {:ok, neighborhoods} = fetch_with_retry(&Api.list_neighborhoods/0) do
      {:noreply, %{projects: projects, neighborhoods: neighborhoods}}
    end
  end

  defp fetch_with_retry(f, retries_remaining \\ 5) do
    case {retries_remaining, f.()} do
      {1, {:error, %HTTPoison.Error{}} = error} ->
        {:error, error}

      {_, _error = %HTTPoison.Error{}} ->
        :timer.sleep(250)
        fetch_with_retry(f, retries_remaining - 1)

      {_, {:ok, result}} ->
        {:ok, result}
    end
  end
end
