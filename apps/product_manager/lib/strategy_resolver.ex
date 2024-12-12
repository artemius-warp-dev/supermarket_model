defmodule StrategyResolver do
  @doc """
  Retrieves the strategy and base price for a given product type.
  """
  def get_product_config(product) do
    # TODO error handling
    Application.get_env(:product_manager, :strategies)
    |> Map.get(String.to_atom(product), nil)
    |> to_struct()
  end

  def update_product_strategy(product, key, value) do
    product
    |> get_product_config()
    |> Map.put(key, value)
  end

  defp to_struct(%{module: module} = map) do
    struct(module, Map.delete(map, :module))
  end

  @doc """
  Calculates the price of a product using its configured strategy.
  """
  def calcualte_price(nil), do: {:error, "Strategy for product not found"}

  def calculate_price(strategy) do
    ProductManager.Strategy.calculate(strategy)
  end
end
