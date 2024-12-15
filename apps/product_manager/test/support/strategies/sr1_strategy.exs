defmodule SR1Strategy do
  @price 500
  @currency :eur
  @product_name :SR1

  @behaviour Strategy
  def calculate(%{price: _price, amount: amount}) when amount >= 3 do
    price = 450
    Float.round(amount * price / 100, 2)
  end

  def calculate(%{price: price, amount: amount}), do: Float.round(amount * price / 100, 2)

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
