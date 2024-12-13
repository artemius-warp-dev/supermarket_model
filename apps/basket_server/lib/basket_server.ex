defmodule BasketServer do
  @moduledoc """
  A server that manages user-specific basket processing.
  """
  require Logger

  use GenServer
  # use Cluster.Node, topologies: [my_cluster: [hosts: :peer]]

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name) #TODO via_tuple
   
    GenServer.start_link(__MODULE__, %{global_name: name}, name: {:global, name})
  end

  def process_basket(super_market, user_id, nil) do
    {:error, :invalid_child_spec}
  end

  def process_basket(server_name, super_market, user_id, basket) do
    GenServer.call({:global, server_name}, {:process_basket, super_market, user_id, basket}, 10_000)
  end

  @impl true
  def init(state) do
    Logger.info("BasketServer: #{state.global_name} started")
    {:ok, state}
  end

  @impl true
  def handle_call({:process_basket, supermarket_id, user_id, basket}, _from, state) do
    {:ok, user_server} =
      UserDynamicSupervisor.start_user_basket(user_id, basket, state.global_name)

    result =
      GenServer.call(user_server, :process_basket, 10_000)

    total_cost = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    response = %{total_cost: total_cost}
    {:reply, {:ok, response}, Map.put(state, user_id, result)}
  end
end
