defmodule NycHousing.Endpoint do
  import Plug.Conn
  alias NycHousing.Lottery.Project

  def index_projects(conn) do
    projects = NycHousing.list_lottery_projects()
    json(conn, Enum.map(projects, &view_project/1))
  end

  def show_project(conn) do
    {id, ""} = Integer.parse(conn.params["project_id"])

    case NycHousing.get_lottery_project(id) do
      %Project{} = project -> json(conn, view_project(project))
      nil -> send_resp(conn, 404, "Not Found")
    end
  end

  defp json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(conn.status || 200, Poison.encode!(data))
  end

  defp view_project(project) do
    %{
      id: project.id,
      name: project.name,
      neighborhoodId: project.neighborhood_id,
      addresses: project.addresses,
      startDate: project.start_date,
      endDate: project.end_date
    }
  end
end
