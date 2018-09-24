defmodule NycHousing do
  alias NycHousing.Lottery

  def get_lottery_project(id), do: Lottery.Store.get_project(id)
  def list_lottery_projects, do: Lottery.Store.list_projects()
  def get_lottery_neighborhood(id), do: Lottery.Store.get_neighborhood(id)
  def list_lottery_neighborhoods, do: Lottery.Store.list_neighborhoods()
end
