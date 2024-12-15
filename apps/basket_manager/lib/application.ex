defmodule BasketManager.Application do
  @moduledoc """
  Starting libcluster for Basket Servers, for test purposes here we start 3 childs for Basket Server to simulate cluster on different nodes
  """
  use Application

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: BasketManager.ClusterSupervisor]]},
      Supervisor.child_spec({BasketServer, name: :basket_server_node1}, id: :basket_server_node1),
      Supervisor.child_spec({BasketServer, name: :basket_server_node2}, id: :basket_server_node2),
      Supervisor.child_spec({BasketServer, name: :basket_server_node3}, id: :basket_server_node3)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end
