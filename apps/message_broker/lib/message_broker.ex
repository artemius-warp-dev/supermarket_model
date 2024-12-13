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
  alias BasketManager

  def route_request(supermarket_id, user_id, items) do
    partition_key = partition(supermarket_id, user_id)
    basket_server = find_basket_server(partition_key)
    basket_manager = Application.get_env(:message_broker, :basket_manager)
    Logger.info("Basket server has been chosen: #{basket_server} from supermarket: #{supermarket_id}")
    case basket_manager.handle_request(basket_server, supermarket_id, user_id, items) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp partition(supermarket_id, user_id) do
    #basket_servers_cluster_size = Application.get_env()
    #IO.inspect({supermarket_id, user_id})
    :erlang.phash2({supermarket_id, user_id}, 3)  #TODO lengh of the servers list
  end

  def find_basket_server(partition_key) do
    cluster_discovery = Application.get_env(:message_broker, :cluster_discovery)
    nodes = cluster_discovery.get_nodes()
    #IO.inspect({nodes, partition_key})
    case Enum.at(nodes, partition_key) do
      nil -> "basket_server_node1" #TODO
      atom -> "basket_server_#{atom}"
    end
    |> String.to_atom()
  end
end

# TODO
# 1. Add logs for DEBUG, espesially for product, user, basket servers
# 2. cluster tests for basket servers
# 3. Research recovery mechanizm
# 4. Work with state
# 5. Create test for 1 million basket and million and for million users
# 6. Research regestry






