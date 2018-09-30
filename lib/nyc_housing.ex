defmodule NycHousing do
  alias NycHousing.Store

  def get_project(id), do: Store.get_project(id)
  def list_projects, do: Store.list_projects()
  def get_neighborhood(id), do: Store.get_neighborhood(id)
  def list_neighborhoods, do: Store.list_neighborhoods()
  def get_borough(id), do: Store.get_borough(id)
  def list_boroughs, do: Store.list_boroughs()
end
