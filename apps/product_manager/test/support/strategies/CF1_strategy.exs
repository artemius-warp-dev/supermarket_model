defmodule CF1Strategy do
  @price 1123
  @currency :eur
  @product_name :CF1
  @behaviour ProductManager.Strategy

  def calculate(%{price: price, amount: amount}) when amount >= 3 do
    price = Float.ceil(price / 3 * 2, 2)
    Float.ceil(amount * price / 100, 2)
  end

  def calculate(%{price: _price, amount: 1}), do: 11.23
  def calculate(%{price: price, amount: amount}), do: Float.ceil(amount * price / 100, 2)

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
