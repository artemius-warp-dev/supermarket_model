defmodule ProductServer.Application do
  use Application

  def start(_type, _args) do

    children = [
      {Registry, keys: :unique, name: ProductServerRegistry},
    ]

    opts = [strategy: :one_for_one, name: ProductServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
