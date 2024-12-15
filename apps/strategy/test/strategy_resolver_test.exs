defmodule StrategyResolverTest do
  use ExUnit.Case

  setup_all do
    StrategyLoader.load_strategies()
    strategies = Application.get_env(:product_manager, :strategies)
    %{strategies: strategies}
  end

  setup do
    :ok
  end

  test "load and process new strategy from file" do
    strategy_path = "../product_manager/test/support/strategies/new/mf1_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)
    new_strategies = Application.get_env(:product_manager, :strategies)
    assert %{module: module, price: price} = Map.get(new_strategies, :MF1_new)

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

    assert total_cost == 22.46
  end
end
