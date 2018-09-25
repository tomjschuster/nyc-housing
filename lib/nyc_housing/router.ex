defmodule NycHousing.Router do
  use Plug.Router
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get("/projects/:project_id", do: NycHousing.Endpoint.show_project(conn))
  # get("/projects", do: NycHousing.Endpoint.index_projects(conn))
  match(_, do: send_resp(conn, 404, "Not Found"))
end
