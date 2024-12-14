defmodule StrategyResolver do
  @doc """
  Retrieves the strategy and base price for a given product type.
  """

  @not_found_msg "Strategy for product not found"

  def get_product_config(product) do
    # TODO error handling
    Application.get_env(:product_manager, :strategies)
    |> Map.get(String.to_atom(product), nil)
    |> to_struct()
  end

  def update_product_strategy(product, key, value) do
    product
    |> get_product_config()
    |> case do
      {:error, _} = err -> err
      term -> Map.put(term, key, value)
    end
  end

  defp to_struct(%{module: module} = map) do
    struct(module, Map.delete(map, :module))
  end

  defp to_struct(_), do: {:error, :not_found}

  @doc """
  Calculates the price of a product using its configured strategy.
  """
  def calculate_price(nil), do: {:error, @not_found_msg}
  def calculate_price({:error, :not_found}), do: {:error, @not_found_msg}

  def calculate_price(strategy) do
    ProductManager.Strategy.calculate(strategy)
  end
end
