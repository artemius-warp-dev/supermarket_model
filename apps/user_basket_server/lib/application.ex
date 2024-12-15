defmodule UserBasketServer.Application do
  use Application

  def start(_type, _args) do

    children = [
      {Registry, keys: :unique, name: UserBasketServerRegistry},
      {Task.Supervisor, name: UserBasketServer.TaskSupervisor}
      
    ]

    opts = [strategy: :one_for_one, name: UserBasketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
