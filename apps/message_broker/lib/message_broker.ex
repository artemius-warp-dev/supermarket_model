defmodule MessageBrokerBehavior do
  @callback route_request(
              supermarket_id :: String.t(),
              user_id :: String.t(),
              items :: list(map())
            ) ::
              {:ok, map()} | {:error, term()}
end

defmodule MessageBroker do
  @behaviour MessageBrokerBehavior
  alias BasketManager

  def route_request(supermarket_id, user_id, items) do
    # Real implementation here
    {:ok, %{total_cost: 100}}
  end

  # def route_request(supermarket_id, user_id, items) do
  #   partition_key = partition(supermarket_id, user_id)
  #   basket_server = find_basket_server(partition_key)

  #   case BasketManager.handle_request(basket_server, supermarket_id, user_id, items) do
  #     {:ok, response} -> {:ok, response}
  #     {:error, reason} -> {:error, reason}
  #   end
  # end

  defp partition(supermarket_id, user_id) do
    # Simple hash-based partitioning strategy
    # Assume 3 partitions
    :erlang.phash2({supermarket_id, user_id}, 3)
  end

  defp find_basket_server(partition_key) do
    # Map partition to a specific GenServer
    :"basket_server_#{partition_key}"
  end
end
