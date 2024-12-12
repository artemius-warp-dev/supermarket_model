defmodule ProductServer do
  use GenServer

  @moduledoc """
  A server that calculates the total cost for a specific product type.
  """

  def start_link({user_id, product_type, items}) do
    GenServer.start_link(__MODULE__, {user_id, product_type, items},
      name: via_tuple(user_id, product_type)
    )
  end

 

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:calculate_cost, _from, {_, type, items} = state) do
    total_cost =
      StrategyResolver.update_product_strategy(type, :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    {:stop, :normal, total_cost, state}
  end

  @impl true
  def terminate(reason, state) do
   
  IO.puts("GenServer stopped because of #{reason}")
  :ok
end

  defp via_tuple(user_id, product_type),
    do: {:global, :"product_server_#{user_id}_#{product_type}"} #TODO
end
