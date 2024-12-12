defmodule StrategyResolverTest do
  use ExUnit.Case

  setup do
    Application.put_env(:product_manager, :strategies, %{
      GR1: %ProductManager.GR1Strategy{price: 311, curency: :eur},
      SR1: %ProductManager.SR1Strategy{price: 500, curency: :eur},
      CF1: %ProductManager.CF1Strategy{price: 1123, curency: :eur}
    })

    :ok
  end

  test "calculates price for tree GR1" do
    items = ["GR1", "GR1", "GR1"]

    total_cost =
      StrategyResolver.update_product_strategy(String.to_atom("GR1"), :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    assert total_cost == 6.22
  end

  test "calculates price for tree SR1" do
    items = ["SR1", "SR1", "SR1"]

    total_cost =
      StrategyResolver.update_product_strategy(String.to_atom("SR1"), :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    assert total_cost == 13.5
  end

  test "calculates price for tree CF1" do
    items = ["CF1", "CF1", "CF1"]

    total_cost =
      StrategyResolver.update_product_strategy(String.to_atom("CF1"), :amount, Enum.count(items))
      |> StrategyResolver.calculate_price()

    assert total_cost == 25.27
  end
end
