defmodule AdmiralStatsParser.Mixfile do
  use Mix.Project

  def project do
    [app: :admiral_stats_parser,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     preferred_cli_env: [espec: :test]]
  end

  defp description do
    """
    Parser for admiral stats JSON data exported from kancolle-arcade.net (Elixir version)
    """
  end

  defp package do
    [
       maintainer: ["Masahiro Yoshizawa"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/muziyoshiz/admiral_stats_parser_ex"}
     ]
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
      {:ex_doc, "~> 0.12", only: :dev},
      {:espec, "~> 1.2.2", only: :test},
    ]
  end
end
