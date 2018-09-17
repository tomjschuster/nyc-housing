defmodule NycHousing do
  @lottery_base "/LttryProject"

  def get_lottery_project(id) do
    Data.NycLottery.get(@lottery_base <> "/GetProject?ProjNo=#{id}")
  end

  def get_lottery_projects do
    Data.NycLottery.get(@lottery_base <> "/GetPublishedCurrentUpcomingProjects")
  end
end
