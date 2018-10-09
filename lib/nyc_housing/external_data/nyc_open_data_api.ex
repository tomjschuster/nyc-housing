defmodule NycHousing.ExternalData.NycOpenDataApi do
  alias __MODULE__.Neighborhood

  def list_neighborhoods do
    with {:ok, %{body: neighborhoods}} <- Neighborhood.get(""), do: {:ok, neighborhoods}
  end

  def list_neighborhoods!, do: Neighborhood.get!("").body
end
