defmodule CF1Strategy do
  @price 1123
  @currency :eur
  @product_name :CF1
  @behaviour Strategy

  def calculate(%{price: price, amount: amount}) when amount >= 3 do
    new_price = Float.round(price / 3 * 2, 2)

    (amount * new_price)
    |> Float.round(2)
    |> Kernel./(100)
    |> Float.round(2)
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
