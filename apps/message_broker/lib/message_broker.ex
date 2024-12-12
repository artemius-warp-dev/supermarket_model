defmodule MessageBrokerBehaviour do
  @callback route_request(
              supermarket_id :: String.t(),
              user_id :: String.t(),
              items :: list(map())
            ) ::
              {:ok, map()} | {:error, term()}
end

defmodule MessageBroker do
  @behaviour MessageBrokerBehaviour
  alias BasketManager

  def route_request(supermarket_id, user_id, items) do
    partition_key = partition(supermarket_id, user_id)
    basket_server = find_basket_server(partition_key)
    basket_manager = Application.get_env(:message_broker, :basket_manager)

    case basket_manager.handle_request(basket_server, supermarket_id, user_id, items) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp partition(supermarket_id, user_id) do
    # TODO fetch from config amount of partitions
    :erlang.phash2({supermarket_id, user_id}, 3)
  end

  def find_basket_server(partition_key) do
    cluster_discovery = Application.get_env(:message_broker, :cluster_discovery)
    nodes = cluster_discovery.get_nodes()
    case Enum.at(nodes, partition_key) do
      nil -> "basket_server_node1"
      atom -> "basket_server_#{atom}"
    end
    
  end
end

# TODO
# 1. Implement core rules for products throught protocols
# 2. Split basket_server on user_server and product_server
# 3. Test whole system
# 4. Research regestry
# 5. Work with state
# 6. End to End tests



# 7. Research recovery mechanizm. 
