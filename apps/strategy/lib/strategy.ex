defmodule Strategy do
  @callback calculate(map()) :: float()
  @callback get_price() :: number()
  @callback get_currency() :: atom()
  @callback get_product_name() :: atom()

end

