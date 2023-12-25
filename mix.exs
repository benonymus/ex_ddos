defmodule ExDdos.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_ddos,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExDdos.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:cachex, "~> 3.6"},
      {:nimble_csv, "~> 1.2"}
    ]
  end
end
