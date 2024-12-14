

defmodule StrategyResolverTest do
  use ExUnit.Case

  setup do
    Application.put_env(:product_manager, :strategies, %{
      GR1: %{module: GR1Strategy, price: 100},
      SR1: %{module: SR1Strategy, price: 200}
    })

    StrategyLoader.load_strategies()
    :ok
  end

  test "load and process new strategy from file" do
    strategy_path = "test/support/strategies/new/mf1_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)
    strategies = Application.get_env(:product_manager, :strategies)
    assert %{module: module, price: price} = Map.get(strategies, :MF1_new)

    strategy = %{price: price, amount: 3}
    assert module.calculate(strategy) == 4.2
  end

  test "calculates price for tree GR1" do
    items = ["GR1", "GR1", "GR1"]

    total_cost =
      StrategyResolver.update_product_strategy("GR1", :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    assert total_cost == 6.22
  end

  test "calculates price for tree SR1" do
    items = ["SR1", "SR1", "SR1"]

    total_cost =
      StrategyResolver.update_product_strategy("SR1", :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    assert total_cost == 13.5
  end

  test "calculates price for tree CF1" do
    items = ["CF1", "CF1", "CF1"]

    total_cost =
      StrategyResolver.update_product_strategy("CF1", :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    assert total_cost == 22.47
  end
end
