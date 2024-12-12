defmodule BasketManager.Application do
  use Application

  # alias BasketManager.PubSub
  # alias BasketManager.BasketServerSupervisor

  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: BasketManager.ClusterSupervisor]]},
      ## {Registry, keys: :unique, name: BasketRegistry}, #TODO
      Supervisor.child_spec({BasketServer, name: :basket_server_node1}, id: :basket_server_node1),
      Supervisor.child_spec({BasketServer, name: :basket_server_node2}, id: :basket_server_node2),
      Supervisor.child_spec({BasketServer, name: :basket_server_node3}, id: :basket_server_node3)
    ]

    IO.inspect("BASKET_MANAGER")
    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
    # start_pubsub_listener()
  end

  ## Subscribe to PubSub events and handle them
  # defp start_pubsub_listener do
  #   PubSub.subscribe()

  #   Task.start(fn ->
  #     receive do
  #       event -> BasketServerSupervisor.handle_event(event)
  #     after
  #       0 -> :ok
  #     end
  #   end)
  # end
end
