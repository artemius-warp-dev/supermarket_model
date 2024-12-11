defmodule MarketStateTest do
 use ExUnit.Case, async: true
  alias MarketState

  setup do
    # Setup environment for testing
    :ok
  end

  test "should store and retrieve market state" do
    supermarket_id = :supermarket_1
    state_data = %{total_basket_count: 5, total_sales: 100}

    # Store state
    :ok = MarketState.store_state(supermarket_id, state_data)

    # Retrieve state and assert correctness
    state = MarketState.get_state(supermarket_id)
    assert state == state_data
  end
end
