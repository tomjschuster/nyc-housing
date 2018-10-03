defmodule NycHousing.Consumers.LotteryConsumer do
  use GenServer

  alias NycHousing.{Store, Repo, Project, Neighborhood, Borough}
  alias NycHousing.ExternalData.LotteryApi

  # 2 hours
  @poll_interval 2 * 60 * 60 * 1000

  # Client
  @spec start_link(term()) ::
          {:ok, pid}
          | :ignore
          | {:error, {:already_started, pid()} | term()}
  def start_link(_arg), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @spec poll() :: :ok
  def poll, do: GenServer.call(__MODULE__, :poll)

  @spec next_poll() :: integer() | false
  def next_poll, do: GenServer.call(__MODULE__, :next_poll)

  # Server
  @impl true
  def init(:ok) do
    with :ok <- poll_all(),
         timer <- schedule_work(),
         do: {:ok, timer}
  end

  @impl true
  def handle_info(:work, _timer) do
    with :ok <- poll_projects(), do: {:noreply, schedule_work()}
  end

  @impl true
  def handle_call(:poll, _from, timer) do
    Process.cancel_timer(timer)
    with :ok <- poll_projects(), do: {:reply, :ok, schedule_work()}
  end

  @impl true
  def handle_call(:next_poll, _from, timer),
    do: {:reply, Process.read_timer(timer), timer}

  # Helpers

  @spec schedule_work() :: reference()
  defp schedule_work, do: Process.send_after(self(), :work, @poll_interval)

  @spec poll_all() :: :ok
  defp poll_all do
    IO.puts("Polling")

    with {:ok, _} <- poll_neighborhoods(),
         {:ok, _} <- poll_boroughs(),
         {:ok, _} <- poll_projects(),
         IO.puts("Polling Complete"),
         do: :ok
  end

  # Projects
  @spec poll_projects() :: :ok
  defp poll_projects do
    projects = Store.list_projects()
    lottery_projects = LotteryApi.list_projects!()
    updated_projects = sync_lottery_projects(projects, lottery_projects)

    with :ok <- Store.refresh_projects(), do: {:ok, updated_projects}
  end

  @spec sync_lottery_projects([%Project{}], [map()]) :: [%Project{}]
  defp sync_lottery_projects(projects, lottery_projects) do
    projects_by_lottery_id = Enum.into(projects, %{}, &{&1.lottery_id, &1})
    lottery_projects_by_id = Enum.into(lottery_projects, %{}, &{&1.lttry_proj_seq_no, &1})

    inserted_and_updated =
      Enum.map(lottery_projects, fn %{lttry_proj_seq_no: lottery_id} = lottery_project ->
        case projects_by_lottery_id do
          %{^lottery_id => project} -> update_project(project, lottery_project)
          %{} -> insert_project(lottery_project)
        end
      end)

    deleted =
      projects
      |> Enum.filter(&(not Map.has_key?(lottery_projects_by_id, &1.lottery_id)))
      |> Enum.map(&(&1 |> Project.deleted_changeset() |> Repo.update!()))

    inserted_and_updated ++ deleted
  end

  @spec insert_project(map()) :: %Project{}
  defp insert_project(lottery_project) do
    lottery_project
    |> add_neighborhood()
    |> add_borough()
    |> Project.lottery_changeset()
    |> Repo.insert!()
  end

  @spec add_neighborhood(map()) :: map()
  defp add_neighborhood(%{neighborhood_lkp: lottery_id} = lottery_project) do
    case Store.get_neighborhood_by_lottery_id(lottery_id) do
      %Neighborhood{id: id} ->
        Map.put(lottery_project, :neighborhood_id, id)

      nil ->
        {:ok, neighborhoods} = poll_neighborhoods()

        id =
          Enum.find_value(neighborhoods, fn n ->
            if n.lottery_id == lottery_id, do: n.id, else: nil
          end)

        Map.put(lottery_project, :neighborhood_id, id)
    end
  end

  @spec add_borough(map()) :: map()
  defp add_borough(%{boro_lkp: lottery_id} = lottery_project) do
    case Store.get_borough_by_lottery_id(lottery_id) do
      %Borough{id: id} ->
        Map.put(lottery_project, :borough_id, id)

      nil ->
        {:ok, boroughs} = poll_boroughs()

        id =
          Enum.find_value(boroughs, fn n ->
            if n.lottery_id == lottery_id, do: n.id, else: nil
          end)

        Map.put(lottery_project, :neighborhood_id, id)
    end
  end

  @spec update_project(%Project{}, map()) :: %Project{}
  defp update_project(project, lottery_project) do
    project
    |> Project.lottery_changeset(lottery_project)
    |> Repo.update!()
  end

  # Neighborhoods
  @spec poll_neighborhoods() :: :ok
  defp poll_neighborhoods do
    neighborhoods = Store.list_neighborhoods()
    lottery_neighborhoods = LotteryApi.list_neighborhoods!()
    updated_neighborhoods = sync_lottery_neighborhoods(neighborhoods, lottery_neighborhoods)

    with :ok <- Store.refresh_neighborhoods(), do: {:ok, updated_neighborhoods}
  end

  @spec sync_lottery_neighborhoods([%Neighborhood{}], [map()]) :: [%Neighborhood{}]
  defp sync_lottery_neighborhoods(neighborhoods, lottery_neighborhoods) do
    neighborhoods_by_lottery_id = Enum.into(neighborhoods, %{}, &{&1.lottery_id, &1})

    Enum.map(lottery_neighborhoods, fn api_neighborhood ->
      neighborhoods_by_lottery_id
      |> Map.get(api_neighborhood.lttry_lookup_seq_no)
      |> Neighborhood.lottery_changeset(api_neighborhood)
      |> Repo.insert_or_update!()
    end)
  end

  # Boroughs
  @spec poll_boroughs() :: :ok
  defp poll_boroughs do
    boroughs = Store.list_boroughs()
    lottery_boroughs = LotteryApi.list_boroughs!()
    updated_boroughs = sync_lottery_boroughs(boroughs, lottery_boroughs)

    with :ok <- Store.refresh_boroughs(), do: {:ok, updated_boroughs}
  end

  @spec sync_lottery_boroughs([%Borough{}], [map()]) :: [%Borough{}]
  defp sync_lottery_boroughs(boroughs, lottery_boroughs) do
    boroughs_by_lottery_id = Enum.into(boroughs, %{}, &{&1.lottery_id, &1})

    Enum.map(lottery_boroughs, fn api_borough ->
      boroughs_by_lottery_id
      |> Map.get(api_borough.lttry_lookup_seq_no)
      |> Borough.lottery_changeset(api_borough)
      |> Repo.insert_or_update!()
    end)
  end
end
