defmodule ProductServer do
  require Logger
  use GenServer

  @moduledoc """
  A server that calculates the total cost for a specific product type.
  """

  def start_link({product_type, items, parent_name}) do
    name = generate_unique_key(parent_name, product_type) |> via_tuple()
    name_for_logs = "#{parent_name}_#_product_server_#{product_type}"

    GenServer.start_link(
      __MODULE__,
      %{name: name_for_logs, type: product_type, items: items},
      name: name
    )
  end

  def init(state) do
    Logger.info("ProductServer started: #{inspect(state.name)}")

    {:ok, state}
  end

  def handle_call(:calculate_cost, _from, state) do
    total_cost =
      StrategyResolver.update_product_strategy(state.type, :amount, Enum.count(state.items))
      |> StrategyResolver.calculate_price()

    {:stop, :normal, total_cost, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:sleep, timeout}, _from, state) do
    Process.sleep(timeout)
    {:reply, :ok, state}
  end

  def terminate(reason, state) do
    Logger.info("ProductServer: #{inspect(state.name)} stopped because of #{reason}")
    :ok
  end

  defp generate_unique_key(parent_server, product_type) do
    "#{parent_server}_#_product_server_#{product_type}_#{:os.system_time(:millisecond)}"
  end

  defp via_tuple(unique_key), do: {:via, Registry, {ProductServerRegistry, unique_key}}
end
