defmodule BasketManagerBehaviour do
  @callback handle_request(
              basket_server :: String.t(),
              supermarket_id :: String.t(),
              user_id :: String.t(),
              items :: list(map()) 
            ) :: {:ok, map()} | {:error, term()}
end

defmodule BasketManager do
  @moduledoc """
  Documentation for `BasketManager`.
  """
  @behaviour BasketManagerBehaviour

  ## Public API for Starting Servers
  def start_basket_servers() do
    config = Application.get_env(:basket_manager, :supermarket_partitions)

    for {supermarket_id, partition_count} <- config do
      for partition <- 1..partition_count do
        BasketServerSupervisor.start_server("#{supermarket_id}_#{partition}", supermarket_id)
      end
    end
  end

  ## Public API for Shutting Down Servers
  def shutdown_basket_server(partition) do
    BasketServerSupervisor.shutdown_basket_server(partition)
  end

  # def start_server(partition, sm_id) do
  #   case DynamicSupervisor.start_child(
  #          BasketSupervisor,
  #          {BasketManager.BasketServer, {partition, sm_id}}
  #        ) do
  #     {:ok, pid} ->
  #       # Monitor the node in case it goes down
  #       Node.monitor(node(pid), true)
  #       {:ok, pid}

  #     {:error, {:already_started, pid}} ->
  #       {:ok, pid}

  #     error ->
  #       error
  #   end
  # end

  def handle_request(basket_server, supermarket_id, user_id, items) do
    # GenServer.call(basket_server, {:process_basket, supermarket_id, user_id, items})
    {:ok, %{}}
  end
end
