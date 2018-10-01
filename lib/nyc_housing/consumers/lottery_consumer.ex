defmodule NycHousing.Consumers.LotteryConsumer do
  use GenServer

  alias NycHousing.{Store, Repo, Project, Neighborhood, Borough}
  alias NycHousing.Services.LotteryApi
  alias Timex.Duration

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

  @spec poll() :: integer() | false
  def next_poll, do: GenServer.call(__MODULE__, :next_poll)

  # Server
  @impl true
  def init(:ok) do
    with :ok <- do_poll(),
         timer <- schedule_work(),
         do: {:ok, timer}
  end

  @impl true
  def handle_info(:work, _timer) do
    with :ok <- do_poll(), do: {:noreply, schedule_work()}
  end

  @impl true
  def handle_call(:poll, _from, timer) do
    Process.cancel_timer(timer)
    with :ok <- do_poll(), do: {:reply, :ok, schedule_work()}
  end

  @impl true
  def handle_call(:next_poll, _from, timer),
    do: {:reply, Process.read_timer(timer), timer}

  # Helpers

  @spec schedule_work() :: reference()
  defp schedule_work, do: Process.send_after(self(), :work, @poll_interval)

  @spec do_poll() :: :ok
  defp do_poll do
    IO.puts("Polling")

    with :ok <- poll_neighborhoods(),
         :ok <- poll_boroughs(),
         :ok <- poll_projects(),
         IO.puts("Polling Complete"),
         do: :ok
  end

  # Projects
  @spec poll_projects() :: :ok
  defp poll_projects do
    projects = Store.list_projects()
    lottery_projects = LotteryApi.list_projects!()
    sync_lottery_projects(projects, lottery_projects)
    Store.refresh_projects()
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
    neighborhood = Store.get_neighborhood_by_lottery_id(lottery_project.neighborhood_lkp)
    borough = Store.get_borough_by_lottery_id(lottery_project.boro_lkp)

    lottery_project
    |> Map.put(:neighborhood_id, neighborhood.id)
    |> Map.put(:borough_id, borough.id)
    |> Project.lottery_changeset()
    |> Repo.insert!()
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
    sync_lottery_neighborhoods(neighborhoods, lottery_neighborhoods)
    Store.refresh_neighborhoods()
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
    sync_lottery_boroughs(boroughs, lottery_boroughs)
    Store.refresh_boroughs()
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
