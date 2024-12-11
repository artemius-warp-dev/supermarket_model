defmodule BasketManager.Application do
  use Application

  alias BasketManager.PubSub
  alias BasketManager.BasketServerSupervisor

  def start(_type, _args) do
    children = [
      ##{Cluster.Supervisor, [Application.get_env(:libcluster, :topologies), [name: ClusterSupervisor]]},
      {Registry, keys: :unique, name: BasketRegistry},
      ##{DynamicSupervisor, strategy: :one_for_one, name: BasketSupervisor},
      ##{BasketManager.CleanupTask, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
    #start_pubsub_listener()
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
