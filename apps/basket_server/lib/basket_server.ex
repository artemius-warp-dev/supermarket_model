defmodule BasketServer do
  @moduledoc """
  A server that manages user-specific basket processing.
  """
  require Logger

  use GenServer
  # use Cluster.Node, topologies: [my_cluster: [hosts: :peer]]

  def start_link(opts) do
    # TODO via_tuple
    name = Keyword.fetch!(opts, :name)

    GenServer.start_link(__MODULE__, %{global_name: name}, name: {:global, name})
  end

  def process_basket(super_market, user_id, nil) do
    {:error, :invalid_child_spec}
  end

  def process_basket(server_name, super_market, user_id, basket) do
    GenServer.call({:global, server_name}, {:process_basket, super_market, user_id, basket})
  end

  @impl true
  def init(state) do
    # Process.flag(:trap_exit, true)
    Logger.info("BasketServer: #{state.global_name} started")
    {:ok, state}
  end

  @impl true
  def handle_call({:process_basket, supermarket_id, user_id, basket}, _from, state) do
    {:ok, user_server} =
      UserDynamicSupervisor.start_user_basket(user_id, basket, state.global_name)

    Process.monitor(user_server)

    response =
      try do
        case GenServer.call(user_server, :process_basket) do
          {:error, reason} ->
            {:error, reason}

          result ->
            total_cost =
              Enum.reduce(result, 0, fn
                {_, value}, acc -> acc + value
              end)

            {:ok, %{total_cost: total_cost}}
        end
      catch
        :exit, reason ->
          {:error, reason}
      end

    {:reply, response, Map.put(state, user_id, response)}
  end

  # def handle_info({:DOWN, ref, :process, _pid, reason}, state) do
  #   IO.inspect({ref, reason, state})
  #   state = Map.delete(state, ref)
  #   {:noreply, {:error, "UserBasketServer crashed: #{inspect(reason)}"}, state}
  # end
end
