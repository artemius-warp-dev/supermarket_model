defmodule BasketServer.Application do
  use Application

  def start(_type, _args) do
    StrategyLoader.load_strategies("../product_manager/test/support/strategies")

    children = [
      {UserDynamicSupervisor, []},
      {ProductDynamicSupervisor, []},
      {Task.Supervisor, name: UserBasketServer.TaskSupervisor}, #TODO
      {Task.Supervisor, name: ProductServer.TaskSupervisor},
      {Task.Supervisor, name: BasketServer.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: BasketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
