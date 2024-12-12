defmodule BasketServerIntTest do
  use ExUnit.Case, async: true

  setup do
    start_supervised(ProductDynamicSupervisor)
    start_supervised(UserDynamicSupervisor)
    {:ok, pid} = BasketServer.start_link([])
    %{pid: pid}
  end

  test "combined basket for [GR1,SR1,GR1,GR1,CF]", %{pid: pid} do
    user_id = "user_1"
    basket = ["GR1", "SR1", "GR1", "GR1", "CF1"]

    result = BasketServer.process_basket(user_id, basket)

    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 22.45
  end

  test "combined basket for [GR1,GR1]", %{pid: pid} do
    user_id = "user_1"
    basket = ["GR1", "GR1"]

    result = BasketServer.process_basket(user_id, basket)

    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 3.11
  end

  test "combined basket for [SR1,SR1,GR1,SR1]", %{pid: pid} do
    user_id = "user_1"
    basket = ["SR1", "SR1", "GR1", "SR1"]

    result = BasketServer.process_basket(user_id, basket)

    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 16.61
  end

    test "combined basket for [GR1,CF1,SR1,CF1,CF1]", %{pid: pid} do
    user_id = "user_1"
    basket = ["GR1","CF1","SR1","CF1","CF1"]

    result = BasketServer.process_basket(user_id, basket)
    IO.inspect(result)
    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 30.57
  end


  
end
