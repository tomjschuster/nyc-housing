defmodule NycHousing.Repo.Migrations.CreateLotteryProject do
  use Ecto.Migration

  def change do
    create table("project") do
      add(:external_id, :integer)
      add(:name, :string)
      add(:borough_id, :integer)
      add(:neighborhood_id, :integer)
      add(:addresses, {:array, :string})
      add(:published_date, :date)
      add(:start_date, :date)
      add(:end_date, :date)
      add(:withdrawn?, :boolean)
      add(:deleted_date, :date)

      timestamps()
    end
  end
end
