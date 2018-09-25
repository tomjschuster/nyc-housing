defmodule NycHousing.Endpoint do
  import Plug.Conn
  alias NycHousing.Lottery.Project

  def show(conn) do
    send_resp(conn, 200, "Hello World!")
  end

  def index_projects(conn) do
    projects = NycHousing.list_projects()
    json(conn, [])
  end

  defp json(conn, data) do
    send_resp(conn, conn.status || 200, "application/json", Poison.encode!(data))
  end
end
