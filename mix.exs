defmodule NycHousing.MixProject do
  use Mix.Project

  def project do
    [
      app: :nyc_housing,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :poison],
      mod: {NycHousing.Application, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:recase, "~> 0.2"},
      {:timex, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.1"},
      {:quantum, "~> 2.3"},
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.6"}
    ]
  end

  defp aliases do
    [
      setup: ["ecto.create", "ecto.migrate"],
      reset: ["ecto.drop", "setup"]
    ]
  end
end
