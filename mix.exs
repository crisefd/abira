defmodule Abira.MixProject do
  use Mix.Project

  def project do
    [
      app: :abira,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sfmt, "~> 0.13.0"},
      {:map_array, git: "https://github.com/crisefd/map_array"}
    ]
  end
end
