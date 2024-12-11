defmodule MarketStateIntegrationTest do
  use ExUnit.Case, async: true
  alias MarketState

  test "should interact with the market state across different systems" do
    supermarket_id = :supermarket_1
    state_data = %{total_basket_count: 5, total_sales: 100}

    # Store the state using MarketState
    :ok = MarketState.store_state(supermarket_id, state_data)

    # Simulate other system interactions (e.g., BasketManager, ApiGateway)
    retrieved_state = MarketState.get_state(supermarket_id)

    # Assert the state remains consistent
    assert retrieved_state == state_data
  end
end
