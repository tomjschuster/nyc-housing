defmodule NycHousing.Repo.Migrations.PollLog do
  use Ecto.Migration

  def change do
    create table "poll_log" do
      add :data_type, :string
      add :source, :string
      add :polled_at, :utc_datetime
    end
  end
end
