defmodule MessageBroker.MixProject do
  use Mix.Project

  def project do
    [
      app: :message_broker,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.17",
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
      {:mox, "~> 1.0.0", only: :test},
      {:basket_manager, in_umbrella: true},
      {:libcluster, "~> 3.4"}
    ]
  end
end