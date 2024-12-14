defmodule ProductManager.MF1Strategy do
  @price 500
  @currency :eur
  @product_name :MF1

  @behaviour ProductManager.Strategy

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
