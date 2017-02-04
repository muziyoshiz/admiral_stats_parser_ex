defmodule AdmiralStatsParser.Mixfile do
  use Mix.Project

  def project do
    [app: :admiral_stats_parser,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     preferred_cli_env: [espec: :test]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # https://github.com/devinus/poison
      {:poison, "~> 3.1"},
      # https://github.com/bitwalker/timex
      # https://hexdocs.pm/timex/getting-started.html
      {:timex, "~> 3.0"},
      {:espec, "~> 1.2.2", only: :test}
    ]
  end
end
