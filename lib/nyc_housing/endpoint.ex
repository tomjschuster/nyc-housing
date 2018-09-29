defmodule NycHousing.Endpoint do
  import Plug.Conn
  alias NycHousing.Lottery.Project

  def index_html(conn) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_file(200, "priv/static/index.html")
  end

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

  def index_neighborhoods(conn) do
    neighborhoods = NycHousing.list_lottery_neighborhoods()
    json(conn, Enum.map(neighborhoods, &view_neighborhood/1))
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

  defp view_neighborhood(neighborhood) do
    %{
      id: neighborhood.id,
      name: neighborhood.name,
      shortName: neighborhood.short_name,
      sortOrder: neighborhood.sort_order,
      startDate: neighborhood.start_date,
      endDate: neighborhood.end_date
    }
  end
end
