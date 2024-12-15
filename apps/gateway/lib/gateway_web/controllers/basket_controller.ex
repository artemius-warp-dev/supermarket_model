defmodule GatewayWeb.BasketController do
  use GatewayWeb, :controller

  alias MessageBroker

  def calculate_basket(conn, %{"supermarket_id" => sm_id, "user_id" => user_id, "items" => items}) do
    message_broker = Application.get_env(:gateway, :message_broker)

    case message_broker.route_request(sm_id, user_id, items) do
      {:ok, response} ->
        json(conn, response)

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: reason})
    end
  end
end
