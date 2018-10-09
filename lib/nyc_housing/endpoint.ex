defmodule NycHousing.Endpoint do
  use Plug.Router
  import Plug.Conn
  alias NycHousing.{Project, Neighborhood, Borough}

  # Plugs

  plug(:match)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  # Routes

  get "/", do: index_html(conn)

  get "/api/projects", do: index_projects(conn)
  get "/api/projects/:project_id", do: show_project(conn)

  get "/api/neighborhoods", do: index_neighborhoods(conn)
  get "/api/neighborhoods/:neighborhood_id", do: show_neighborhood(conn)

  get "/api/boroughs", do: index_boroughs(conn)
  get "/api/boroughs/:borough_id", do: show_borough(conn)

  match _, do: send_resp(conn, 404, "Not Found")

  # Actions

  def index_html(conn) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_file(200, "priv/static/index.html")
  end

  def index_projects(conn) do
    projects = NycHousing.list_projects()
    json(conn, Enum.map(projects, &view_project/1))
  end

  def show_project(conn) do
    {id, ""} = Integer.parse(conn.params["project_id"])

    case NycHousing.get_project(id) do
      %Project{} = project -> json(conn, view_project(project))
      nil -> send_resp(conn, 404, "Not Found")
    end
  end

  def index_neighborhoods(conn) do
    neighborhoods = NycHousing.list_neighborhoods()
    json(conn, Enum.map(neighborhoods, &view_neighborhood/1))
  end

  def show_neighborhood(conn) do
    {id, ""} = Integer.parse(conn.params["neighborhood_id"])

    case NycHousing.get_neighborhood(id) do
      %Neighborhood{} = neighborhood -> json(conn, view_neighborhood(neighborhood))
      nil -> send_resp(conn, 404, "Not Found")
    end
  end

  def index_boroughs(conn) do
    boroughs = NycHousing.list_boroughs()
    json(conn, Enum.map(boroughs, &view_borough/1))
  end

  def show_borough(conn) do
    {id, ""} = Integer.parse(conn.params["borough_id"])

    case NycHousing.get_borough(id) do
      %Borough{} = borough -> json(conn, view_borough(borough))
      nil -> send_resp(conn, 404, "Not Found")
    end
  end

  defp json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(conn.status || 200, Poison.encode!(data))
  end

  # Views

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
      sortOrder: neighborhood.sort_order
    }
  end

  defp view_borough(borough) do
    %{
      id: borough.id,
      name: borough.name,
      shortName: borough.short_name,
      sortOrder: borough.sort_order
    }
  end
end
