defmodule NycHousing.PollLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "poll_log" do
    field :data_type, :string
    field :source, :string
    field :polled_at, :utc_datetime
  end

  def changeset(data_type, source) do
    params = %{data_type: data_type, source: source, polled_at: DateTime.utc_now()}
    cast(%PollLog{}, params, [:data_type, :source, :polled_at])
  end
end
