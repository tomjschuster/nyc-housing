defmodule NycHousing.Router do
  use Plug.Router

  # plug(Plug.Static, from: "priv/static/")
  plug(:match)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get("/", do: NycHousing.Endpoint.index_html(conn))
  get("/api/lottery/projects/:project_id", do: NycHousing.Endpoint.show_project(conn))
  get("/api/lottery/projects", do: NycHousing.Endpoint.index_projects(conn))
  get("/api/lottery/neighborhoods", do: NycHousing.Endpoint.index_neighborhoods(conn))
  match(_, do: send_resp(conn, 404, "Not Found"))
end
