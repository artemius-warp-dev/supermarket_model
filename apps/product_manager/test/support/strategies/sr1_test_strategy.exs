defmodule SR1TestStrategy do
  @price 500
  @currency :eur
  @product_name :SR1_test

  @behaviour ProductManager.Strategy

  def calculate(%{price: price, amount: amount}) when amount >= 3 do
    price = 450
    Process.sleep(1000)
    Float.ceil(amount * price / 100, 2)
  end

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
