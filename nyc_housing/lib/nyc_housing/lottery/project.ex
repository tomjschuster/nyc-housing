defmodule NycHousing.Lottery.Project do
  alias __MODULE__

  defstruct [
    :id,
    :name,
    :neighborhood_id,
    :addresses,
    :start_date,
    :end_date,
    :published?,
    :published_date,
    :withdrawn?,
    :deleted?,
    :deleted_date
  ]
end
