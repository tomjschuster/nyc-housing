defmodule NycHousing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      NycHousing.Repo,
      NycHousing.Scheduler,
      NycHousing.Lottery.Store
      # Starts a worker by calling: NycHousing.Worker.start_link(arg)
      # {NycHousing.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NycHousing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
