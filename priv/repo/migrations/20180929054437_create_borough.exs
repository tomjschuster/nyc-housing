defmodule NycHousing.Repo.Migrations.CreateBorough do
  use Ecto.Migration

  def change do
    create table "borough" do
      add :name, :string
      add :short_name, :string
      add :sort_order, :integer
      add :lottery_id, :integer

      timestamps()
    end
  end
end
