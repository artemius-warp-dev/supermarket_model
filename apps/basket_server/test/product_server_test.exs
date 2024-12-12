defmodule BasketServer.ProductServerTest do
  use ExUnit.Case, async: true

  alias ProductServer

  setup do
    user_id = "user_1"
    product_type = String.to_atom("GR1")
    items = ["GR1", "GR1", "GR1"]
    ##{:ok, pid} = ProductServer.start_link({user_id, product_type, items})
    %{items: items, product_type: product_type, user_id: user_id}
  end

  test "calculates total cost for products", %{pid: pid, items: items} do
    total_price = GenServer.call(pid, {:calculate_cost, items})
    assert total_price == 20
  end

  test "stops after processing items", %{pid: pid, items: items} do
    _total_price = GenServer.call(pid, {:calculate_cost, items})
    refute Process.alive?(pid)
  end

  # TODO integration tests

  test "tree GR1", %{user_id: user_id} do
    items = ["GR1", "GR1", "GR1"]
    {:ok, pid} = ProductServer.start_link({user_id, String.to_atom("GR1"), items})
    total_cost = GenServer.call(pid, :calculate_cost)

    assert total_cost == 6.22
  end

  test "tree SR1", %{user_id: user_id}  do
    items = ["SR1", "SR1", "SR1"]
    {:ok, pid} = ProductServer.start_link({user_id, String.to_atom("SR1"), items})
    total_cost = GenServer.call(pid, :calculate_cost)
    assert total_cost == 13.5
  end

  test "tree CF1", %{user_id: user_id}  do
    items = ["CF1", "CF1", "CF1"]
    {:ok, pid} = ProductServer.start_link({user_id, String.to_atom("CF1"), items})
    total_cost = GenServer.call(pid, :calculate_cost)
    assert total_cost == 25.27
  end
end
