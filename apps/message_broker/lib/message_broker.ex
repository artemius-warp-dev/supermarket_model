defmodule MessageBrokerBehaviour do
  @callback route_request(
              supermarket_id :: String.t(),
              user_id :: String.t(),
              items :: list(map())
            ) ::
              {:ok, map()} | {:error, term()}
end

defmodule MessageBroker do
  require Logger
  @behaviour MessageBrokerBehaviour

  def route_request(supermarket_id, user_id, items) do
    partition_key = partition(supermarket_id, user_id)
    basket_server = find_basket_server(partition_key)
    basket_manager = Application.get_env(:message_broker, :basket_manager)

    Logger.info(
      "Basket server has been chosen: #{basket_server} from supermarket: #{supermarket_id}"
    )

    case basket_manager.handle_request(basket_server, supermarket_id, user_id, items) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp partition(supermarket_id, user_id) do
    cluster_lenght = length(fetch_hosts())
    :erlang.phash2({supermarket_id, user_id}, cluster_lenght)
  end

  def find_basket_server(partition_key) do
    cluster_discovery = Application.get_env(:message_broker, :cluster_discovery)
    nodes = cluster_discovery.get_nodes()

    case Enum.at(nodes, partition_key) do
      nil -> "basket_server_node1"
      atom -> "basket_server_#{atom}"
    end
    |> String.to_atom()
  end

  defp fetch_hosts() do
    Application.get_env(:libcluster, :topologies)
    |> Keyword.get(:basket_server_cluster, [])
    |> Keyword.get(:config, [])
    |> Keyword.get(:hosts, [])
  end
end
