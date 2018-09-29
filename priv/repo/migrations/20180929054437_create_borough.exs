defmodule NycHousing.Repo.Migrations.CreateBorough do
  use Ecto.Migration

  def change do
    create table("borough") do
      add(:external_id, :integer)
      add(:name, :string)
      add(:short_name, :string)
      add(:sort_order, :integer)

      timestamps()
    end
  end
end
