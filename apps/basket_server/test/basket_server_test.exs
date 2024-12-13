defmodule BasketServerTest do
  use ExUnit.Case, async: true

  setup do
    #start_supervised(ProductDynamicSupervisor) 
    #start_supervised(UserDynamicSupervisor) 
    {:ok, pid} = BasketServer.start_link([])
    %{pid: pid}
  end

  test "start and processes a user's basket", %{pid: pid} do
    user_id = "user_123"

    basket = [
      %{type: :fruit},
      %{type: :vegetable}
    ]

    result = BasketServer.process_basket(user_id, basket)

    assert Process.alive?(pid)

    state = :sys.get_state(pid)
    assert Map.has_key?(state, user_id)
    #assert state[user_id] = %{fruit: 10, vegetable: 10} #TODO use mocks
  end

  test "handles invalid basket gracefully", %{pid: pid} do
    user_id = "user_invalid"
    basket = nil
    super_market = "sp1"

    result = BasketServer.process_basket(super_market, user_id, basket)
    assert result == {:error, :invalid_child_spec}

    state = :sys.get_state(pid)
    refute Map.has_key?(state, user_id)
  end



end
