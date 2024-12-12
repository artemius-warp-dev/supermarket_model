defmodule ProductManagerTest do
  use ExUnit.Case



  setup do
    Application.put_env(:product_manager, :strategies, %{
      GR1: %ProductManager.GR1Strategy{price: 100},
      SR1: %ProductManager.SR1Strategy{price: 50},
      CF1: %ProductManager.CF1Strategy{price: 150}
    }) 

    :ok
  end


   test "calculates price for GR1 using initial configuration" do
    assert StrategyResolver.calculate_price(:GR1) == 110.0
  end

  test "calculates price for SR1 using initial configuration" do
    assert StrategyResolver.calculate_price(:SR1) == 60.0
  end

  test "calculates price for CF1 using initial configuration" do
    assert StrategyResolver.calculate_price(:CF1) == 200.0
  end

  test "returns error for unknown product" do
    assert StrategyResolver.calculate_price(:unknown) == {:error, "Strategy for product not found"}
  end

  test "dynamically changes strategy for SR1 at runtime" do
    Application.put_env(:product_manager, :strategies,  %{
      GR1: %ProductManager.GR1Strategy{price: 100},
      SR1: %ProductManager.SR1Strategy{price: 20},
      CF1: %ProductManager.CF1Strategy{price: 150}
    })

    assert StrategyResolver.calculate_price(:SR1) == 24
  end

  test "dynamically changes base price for green_tea at runtime" do
    Application.put_env(:product_manager, :strategies,  %{
      GR1: %ProductManager.GR1Strategy{price: 100},
      SR1: %ProductManager.SR1Strategy{price: 50},
      CF1: %ProductManager.CF1Strategy{price: 120}
    })

    assert StrategyResolver.calculate_price(:GR1) == 110
  end

  test "dynamically adds a new product at runtime" do
    Application.put_env(:product_manager, :strategies,  %{
      GR1: %ProductManager.GR1Strategy{price: 100},
      SR1: %ProductManager.SR1Strategy{price: 50},
      CF1: %ProductManager.CF1Strategy{price: 120}
      #MF1: %ProductManager.MF1Strategy{price: 500} #TODO try macros here
    })

    assert StrategyResolver.calculate_price(:MF1) == 125.0
  end

  test "removes a product from configuration at runtime" do

    
    new_config_map =
    :product_manager
     |> Application.get_env(:strategies)
     |> Map.delete(:SR1)
     Application.put_env(:product_manager, :strategies, new_config_map)

    assert StrategyResolver.calculate_price(:SR1) == {:error, "Strategy for product not found"}
  end
   
end
