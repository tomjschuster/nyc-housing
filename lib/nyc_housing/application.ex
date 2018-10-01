defmodule NycHousing.Application do
  use Application

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: NycHousing.Endpoint,
        options: [port: 4000]
      ),
      NycHousing.Repo,
      NycHousing.Store,
      NycHousing.Consumers.LotteryConsumer
    ]

    opts = [strategy: :one_for_one, name: NycHousing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
