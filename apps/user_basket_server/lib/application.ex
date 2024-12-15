defmodule UserBasketServer.Application do
  use Application

  def start(_type, _args) do

    children = [
      {Registry, keys: :unique, name: UserBasketServerRegistry},
    ]

    opts = [strategy: :one_for_one, name: UserBasketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
