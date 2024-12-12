defmodule UserBasketServer do
  use GenServer

  @moduledoc """
  A server that processes a user's basket by splitting it into product groups.
  """

  def start_link({user_id, basket}) do
    GenServer.start_link(__MODULE__, {user_id, basket}, name: via_tuple(user_id))
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:process_basket, _from, {user_id, basket}) do
    product_groups = split_by_product(basket)

    results =
      Enum.reduce(product_groups, %{}, fn {product_type, items}, acc ->
        Map.put(acc, product_type, process_product_group(user_id, product_type, items))
      end)

    {:stop, :normal, results, {user_id, results}}
  end

  def handle_call(:get_state, _from, state) do
    # TODO implement some state here
  end

  # TODO use regestry
  defp via_tuple(user_id), do: {:global, :"user_basket_server_#{user_id}"}

  defp split_by_product(basket) do
    Enum.group_by(basket, fn product -> product end)  #TODO short version
  end

  defp process_product_group(user_id, product_type, items) do
    server_name = product_server_name(user_id, product_type)
    {:ok, pid} = ProductDynamicSupervisor.start_product_server(user_id, product_type, items)
    GenServer.call(pid, :calculate_cost)
  end

  defp product_server_name(user_id, product_type),
    do: :"product_server_#{user_id}_#{product_type}"
end
