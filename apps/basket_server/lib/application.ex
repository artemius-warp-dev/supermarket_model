defmodule BasketServer.Application do
  @moduledoc """
  Starting User Basket Server and Product Server dynamic supervisors, and supervisor for Basket server tasks as well
  """
  use Application

  def start(_type, _args) do
    StrategyLoader.load_strategies("../product_manager/test/support/strategies")

    children = [
      {UserDynamicSupervisor, []},
      {ProductDynamicSupervisor, []},
      {Task.Supervisor, name: BasketServer.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: BasketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
