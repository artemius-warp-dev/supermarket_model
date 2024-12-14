defmodule ProductManagerTest do
  use ExUnit.Case

  setup do
    Application.put_env(:product_manager, :strategies, %{
      GR1: %{module: GR1Strategy, price: 100},
      SR1: %{module: SR1Strategy, price: 200}
    })

    StrategyLoader.load_strategies()
    :ok
  end

  test "calculates price for GR1 using initial configuration" do
    total_cost =
      StrategyResolver.update_product_strategy("GR1", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert total_cost == 3.11
  end

  test "calculates price for SR1 using initial configuration" do
    total_cost =
      StrategyResolver.update_product_strategy("SR1", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert total_cost == 5.0
  end

  test "calculates price for CF1 using initial configuration" do
    total_cost =
      StrategyResolver.update_product_strategy("CF1", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert total_cost == 11.23
  end

  test "returns error for unknown product" do
    res =
      StrategyResolver.update_product_strategy("unknown", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert res == {:error, "Strategy for product not found"}
  end

  test "dynamically changes strategy for SR1 at runtime" do
    Application.put_env(:product_manager, :strategies, %{
      GR1: %{module: GR1Strategy, price: 100},
      SR1: %{module: SR1Strategy, price: 20},
      CF1: %{module: CF1Strategy, price: 150}
    })

    total_cost =
      StrategyResolver.update_product_strategy("SR1", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert total_cost == 0.2
  end

  test "dynamically changes base price for green_tea at runtime" do
    Application.put_env(:product_manager, :strategies, %{
      GR1: %{module: GR1Strategy, price: 1000},
      SR1: %{module: SR1Strategy, price: 20},
      CF1: %{module: CF1Strategy, price: 150}
    })

    total_cost =
      StrategyResolver.update_product_strategy("GR1", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert total_cost == 10.0
  end

  test "dynamically adds a new product at runtime" do
    strategy_path = "test/support/strategies/new/mf1_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)

    total_cost =
      StrategyResolver.update_product_strategy("MF1_new", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert total_cost == 1.4
  end

  test "removes a product from configuration at runtime" do
    new_config_map =
      :product_manager
      |> Application.get_env(:strategies)
      |> Map.delete(:SR1)

    Application.put_env(:product_manager, :strategies, new_config_map)

    res =
      StrategyResolver.update_product_strategy("SR1", :amount, 1)
      |> StrategyResolver.calculate_price()

    assert res == {:error, "Strategy for product not found"}
  end
end
