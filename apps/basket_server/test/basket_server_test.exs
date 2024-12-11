defmodule BasketServerTest do

  use ExUnit.Case, async: true

 

 setup do
    # Start BasketManager explicitly to ensure the registry is available
    Application.ensure_all_started(:basket_manager)
    
    # Start BasketServer for the test
    {:ok, basket_server_pid} = BasketServer.start_link({:supermarket_id, :partition_id})
    
    # Return the PID of the basket server to be used in the tests
    {:ok, basket_server: basket_server_pid}
  end


  test "initial state is empty basket", %{pid: pid} do
    assert BasketServer.get_state(pid, "supermarket_1") == %{items: [], total: 0}
  end

  # test "add item updates the basket", %{pid: pid} do
  #   BasketServer.add_item(pid, %{id: "item_1", price: 100, quantity: 2})
  #   assert BasketServer.get_state(pid) == %{items: [%{id: "item_1", price: 100, quantity: 2}], total: 200}
  # end

  # test "remove item updates the basket", %{pid: pid} do
  #   BasketServer.add_item(pid, %{id: "item_1", price: 100, quantity: 2})
  #   BasketServer.remove_item(pid, "item_1")
  #   assert BasketServer.get_state(pid) == %{items: [], total: 0}
  # end
  
end
