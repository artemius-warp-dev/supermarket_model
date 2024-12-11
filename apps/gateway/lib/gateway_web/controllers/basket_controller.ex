defmodule GatewayWeb.BasketController do
  use GatewayWeb, :controller

  alias MessageBroker

  def calculate_basket(conn, %{"supermarket_id" => sm_id, "user_id" => user_id, "items" => items}) do
    message_broker = Application.get_env(:gateway, :message_broker, MessageBroker)

    case message_broker.route_request(sm_id, user_id, items) do
      {:ok, response} -> json(conn, response)
      {:error, reason} -> json(conn, %{error: reason})
    end
  end
end
