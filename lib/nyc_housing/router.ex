defmodule NycHousing.Router do
  use Plug.Router
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get("/projects", do: NycHousing.Endpoint.index_projects(conn))
  get("/hello", do: NycHousing.Endpoint.show(conn))
  match(_, do: send_resp(conn, 404, "Not Found"))
end
