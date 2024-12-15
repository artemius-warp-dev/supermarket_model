defmodule StrategyLoader do
  @strategy_dir "../product_manager/test/support/strategies"

  def load_strategies(path \\ @strategy_dir) do
    path
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.each(&load_strategy/1)

    Application.get_env(:product_manager, :strategies, %{})
    
  end

  
  def load_strategy(script_path) do
    unless File.exists?(script_path) do
      raise "Strategy file not found at #{script_path}"
    end
    
    [{module, _binary}] = Code.compile_file(script_path)

    current_strategies = Application.get_env(:product_manager, :strategies, %{})
    strategy = %{module: module, price: module.get_price(), currency: module.get_currency()}
    updated_strategies = Map.put(current_strategies, module.get_product_name(), strategy)

    Application.put_env(:product_manager, :strategies, updated_strategies)
  end
end
