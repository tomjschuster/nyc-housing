defmodule NycHousing.Endpoint do
  import Plug.Conn
  alias NycHousing.Lottery.Project

  def show(conn) do
    send_resp(conn, 200, "Hello World!")
  end

  def index_projects(conn) do
    projects = NycHousing.list_lottery_projects()
    json(conn, [])
  end

  def show_project(conn) do
    IO.inspect(conn)
    {id, ""} = Integer.parse(conn.params["project_id"])
    project = NycHousing.get_lottery_project(id)
    json(conn, %{})
  end

  defp json(conn, data) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(conn.status || 200, Poison.encode!(data))
  end
end
