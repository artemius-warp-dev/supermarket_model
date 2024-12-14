defmodule ProductManager.MF1Strategy do
  @price 140
  @currency :eur
  @product_name :MF1_new

  @behaviour ProductManager.Strategy

  # Implement the calculate/1 callback defined in the ProductManager.Strategy behavior
  def calculate(%{price: price, amount: amount}) do
    Float.round(price * amount / 100, 2)
  end

  def get_price do
    @price
  end

  def get_currency do
    @currency
  end

  def get_product_name do
    @product_name
  end
end
