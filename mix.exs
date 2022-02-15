defmodule Needlework.MixProject do
  use Mix.Project

  @source_url "https://github.com/mpanarin/needlework"
  @version "0.0.1"

  def project do
    [
      app: :needlework,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      # Docs
      name: "Needlework",
      source_url: @source_url,
      docs: docs(),
      # dialyzer
      dialyzer: dialyzer()
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: [
        "README.md"
      ]
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: []
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:versioce, "~> 1.1", only: [:dev], optional: true, runtime: false},
      {:git_cli, "~> 0.3.0", only: [:dev], optional: true, runtime: false},
      {:ex_doc, "~> 0.22", only: [:release, :dev]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
