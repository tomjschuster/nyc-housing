defmodule NycHousing.Repo.Migrations.CreateLotteryProject do
  use Ecto.Migration

  def change do
    create table("project") do
      add(:name, :string)
      add(:borough_id, :integer)
      add(:neighborhood_id, :integer)
      add(:addresses, {:array, :string})
      add(:published_date, :date)
      add(:start_date, :date)
      add(:end_date, :date)
      add(:deleted_date, :date)
      add(:lottery_id, :integer)

      timestamps()
    end
  end
end
