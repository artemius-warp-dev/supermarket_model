defmodule BasketServerTest do
  use ExUnit.Case

  setup do
    strategies = %{
      CF1: %{currency: :eur, module: CF1Strategy, price: 1123},
      CF1_test: %{currency: :eur, module: CF1TestStrategy, price: 500},
      GR1: %{currency: :eur, module: GR1Strategy, price: 311},
      GR1_test: %{currency: :eur, module: GR1TestStrategy, price: 500},
      MF1: %{currency: :eur, module: MF1Strategy, price: 500},
      SR1: %{currency: :eur, module: SR1Strategy, price: 500},
      SR1_test: %{currency: :eur, module: SR1TestStrategy, price: 500}
    }

    Application.put_env(:product_manager, :strategies, strategies)
    name = :test
    user_id = "user_123"
    super_market = "sp1"
    {:ok, pid} = BasketServer.start_link(name: name)
    %{pid: pid, name: name, user_id: user_id, super_market: super_market}
  end

  test "start and processes a user's basket", state do
    basket = ["FF1", "SS2"]

    BasketServer.process_basket(state.name, state.super_market, state.user_id, basket)

    assert Process.alive?(state.pid)

    server_state = :sys.get_state(state.pid)
    assert Map.has_key?(server_state, state.user_id)
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
