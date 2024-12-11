defmodule GatewayTest do
  use GatewayWeb.ConnCase, async: true

  import Mox
  alias GatewayWeb.BasketController

  Mox.defmock(MessageBrokerMock, for: MessageBrokerBehavior)

  setup :verify_on_exit!

  test "calculate_basket returns basket total cost", %{conn: conn} do
    supermarket_id = "supermarket_1"
    user_id = "user_123"
    items = [%{product_id: "p1", quantity: 2}]


    MessageBrokerMock
    |> expect(:route_request, fn ^supermarket_id, ^user_id, ^items ->
      {:ok, %{total_cost: 100}}
    end)

    response =
      BasketController.calculate_basket(
        conn,
        %{"supermarket_id" => supermarket_id, "user_id" => user_id, "items" => items}
      )

    assert response.status == 200
    assert response.resp_body == Jason.encode!(%{total_cost: 100})
  end

  test "calculate_basket handles error response", %{conn: conn} do
    supermarket_id = "supermarket_1"
    user_id = "user_123"
    items = [%{product_id: "p1", quantity: 2}]

    MessageBrokerMock
    |> expect(:route_request, fn ^supermarket_id, ^user_id, ^items ->
      {:error, "Invalid data"}
    end)

    response =
      BasketController.calculate_basket(
        conn,
        %{"supermarket_id" => supermarket_id, "user_id" => user_id, "items" => items}
      )

    assert response.status == 200
    assert response.resp_body == Jason.encode!(%{error: "Invalid data"})
  end
end
