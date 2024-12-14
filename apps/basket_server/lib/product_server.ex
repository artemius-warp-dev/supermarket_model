defmodule ProductServer do
  require Logger
  use GenServer

  @moduledoc """
  A server that calculates the total cost for a specific product type.
  """

  def start_link({product_type, items, parent_name}) do
    name = via_atom(product_type, parent_name)
    GenServer.start_link(
      __MODULE__,
      %{name: name, type: product_type, items: items},
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
      |> IO.inspect()

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

  defp via_atom(type, parent_server), do: "#{parent_server}_#_product_server_#{type}" |> String.to_atom()
end
