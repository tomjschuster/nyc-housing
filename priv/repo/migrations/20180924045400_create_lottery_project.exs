defmodule NycHousing.Repo.Migrations.CreateLotteryProject do
  use Ecto.Migration

  def change do
    create table("lottery_project") do
      add(:external_id, :integer)
      add(:name, :string)
      add(:neighborhood_id, :integer)
      add(:addresses, {:array, :string})
      add(:start_date, :date)
      add(:end_date, :date)
      add(:published?, :boolean)
      add(:published_date, :date)
      add(:withdrawn?, :boolean)
      add(:deleted_date, :date)

      timestamps()
    end
  end
end
