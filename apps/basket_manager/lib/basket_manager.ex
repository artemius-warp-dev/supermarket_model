defmodule BasketManagerBehaviour do
  @callback handle_request(
              basket_server :: String.t(),
              supermarket_id :: String.t(),
              user_id :: String.t(),
              items :: list(map())
            ) :: {:ok, map()} | {:error, term()}
end

defmodule BasketManager do
  @moduledoc """
  Documentation for `BasketManager`.
  """
  @behaviour BasketManagerBehaviour

  def handle_request(basket_server, supermarket_id, user_id, items) do
    GenServer.call(
      {:global, basket_server},
      {:process_basket, supermarket_id, user_id, items},
      7000
    )
  end
end
