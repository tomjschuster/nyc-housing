defmodule NycHousing.MixProject do
  use Mix.Project

  def project do
    [
      app: :nyc_housing,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NycHousing.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:recase, "~> 0.2"},
      {:timex, "~> 3.1"}
    ]
  end
end
