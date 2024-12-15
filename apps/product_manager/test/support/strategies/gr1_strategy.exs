defmodule GR1Strategy do
  @price 311
  @currency :eur
  @product_name :GR1

  @behaviour Strategy

  def calculate(%{price: price, amount: amount}) do
    min_units =
      for i <- 1..amount, rem(i, 2) != 0, reduce: 0 do
        acc -> acc + price
      end

    Float.round(min_units / 100, 2)
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
