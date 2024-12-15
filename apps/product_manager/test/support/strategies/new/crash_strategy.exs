defmodule CrashStrategy do
  @price 500
  @currency :eur
  @product_name :crash

  @behaviour Strategy

  def calculate(%{price: price, amount: amount}) do
    raise RuntimeError
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
