defmodule NycHousing.Consumers.Log do
  alias NycHousing.{Repo, PollLog}
  import Ecto.Query
  @data_types [:neighborhood, :borough, :project]
  @sources [:nyc_open_data, :nyc_lottery]

  def log_nyc_open_data_neighborhoods,
    do: log_poll(:neighborhood, :nyc_open_data)

  def nyc_open_data_neighborhoods_last_polled,
    do: last_polled(:neighborhood, :nyc_open_data)

  def log_lottery_neighborhood, do: log_poll(:neighborhood, :nyc_lottery)
  def log_lottery_borough, do: log_poll(:borough, :nyc_lottery)
  def log_lottery_project, do: log_poll(:project, :nyc_lottery)

  def lottery_neighborhood_last_polled, do: last_polled(:neighborhood, :nyc_lottery)
  def lottery_borough_last_polled, do: last_polled(:borough, :nyc_lottery)
  def lottery_project_last_polled, do: last_polled(:project, :nyc_lottery)

  defp log_poll(data_type, source)
       when data_type in @data_types and source in @sources do
    changeset = PollLog.changeset(Atom.to_string(data_type), Atom.to_string(source))
    with {:ok, _} <- Repo.insert(changeset), do: :ok
  end

  defp last_polled(data_type, source) do
    poll_query(data_type, source)
    |> first(:polled_at)
    |> Repo.one()
  end

  defp poll_query(data_type, source)
       when data_type in @data_types and source in @sources do
    data_type_string = Atom.to_string(data_type)
    source_string = Atom.to_string(source)

    from p in PollLog,
      where: [data_type: ^data_type_string, source: ^source_string],
      order_by: [desc: p.polled_at]
  end
end
