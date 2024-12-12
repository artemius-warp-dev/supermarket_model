defmodule BasketServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :basket_server,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      #included_applications: [:basket_manager]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {BasketServer.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
      {:mox, "~> 1.0", only: :test},
      {:market_state, in_umbrella: true},
      {:basket_manager, in_umbrella: true},
      {:product_manager, in_umbrella: true}
    ]
  end
end
