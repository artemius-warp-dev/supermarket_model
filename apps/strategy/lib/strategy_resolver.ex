defmodule StrategyResolver do
  @moduledoc """
  Retrieves the strategy and base price for a given product type.
  """

  @not_found_msg "Strategy for product not found"

  def get_product_config(product) do
    Application.get_env(:product_manager, :strategies)
    |> Map.get(String.to_atom(product), nil)
  end

  def update_product_strategy(product, key, value) do
    product
    |> get_product_config()
    |> case do
      {:error, _} = err -> err
      nil -> nil
      term -> Map.put(term, key, value)
    end
  end

  @doc """
  Calculates the price of a product using its configured strategy.
  """
  def calculate_price(nil), do: {:error, @not_found_msg}
  def calculate_price({:error, :not_found}), do: {:error, @not_found_msg}

  def calculate_price(%{module: module} = strategy) do
    module.calculate(strategy)
  end
end
