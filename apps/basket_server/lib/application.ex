defmodule BasketServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      {UserDynamicSupervisor, []},
      {ProductDynamicSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: BasketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end