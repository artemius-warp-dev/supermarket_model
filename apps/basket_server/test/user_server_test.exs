defmodule BasketServer.UserBasketServerTest do
  use ExUnit.Case, async: true

  alias UserBasketServer

  setup do
    user_id = "user_123"
    basket = [
      %{type: :fruit},
      %{type: :fruit},
      %{type: :vegetable}
    ]
    {:ok, pid} = UserBasketServer.start_link({user_id, basket})
    start_supervised(ProductDynamicSupervisor)
    %{pid: pid, basket: basket, user_id: user_id}
  end

  test "processes items and calculates totals", %{pid: pid, basket: basket} do
    result = GenServer.call(pid, :process_basket)
    assert %{fruit: 20, vegetable: 10} = result
  end

  # TODO
  # test "returns state correctly", %{pid: pid, basket: basket, user_id: user_id} do
  #   state = GenServer.call(pid, :get_state)
  #   assert state == %{user_id: user_id, basket: basket, processed: false}
  # end
end
