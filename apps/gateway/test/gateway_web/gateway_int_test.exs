defmodule GatewayIntegrationTest do
  use GatewayWeb.ConnCase

  alias ApiGateway

  setup do
    Application.put_env(:gateway, :message_broker, MessageBroker)
    :ok

    on_exit(fn ->
      Application.put_env(:gateway, :message_broker, MessageBrokerMock)
    end)
  end

  test "should handle API request and process basket", %{conn: conn} do
    res =
      conn
      |> post("/api/basket", %{"supermarket_id" => 1, "user_id" => 1, "items" => %{}})
      |> json_response(200)

    assert res == %{"total_cost" => 100}
  end
end
