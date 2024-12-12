defmodule GatewayIntegrationTest do
  use GatewayWeb.ConnCase, async: true

  import Mox

  alias ApiGateway

  setup do
    Application.put_env(:gateway, :message_broker, MessageBroker)
    Application.put_env(:message_broker, :basket_manager, BasketManager)
    Application.put_env(:message_broker, :cluster_discovery, ClusterDiscovery)
    :ok

    on_exit(fn ->
      Application.put_env(:gateway, :message_broker, MessageBrokerMock)
      Application.put_env(:message_broker, :basket_manager, BasketManagerMock)
      Application.put_env(:message_broker, :cluster_discovery, ClusterDiscoveryMock)
    end)
  end

  test "empty basket", %{conn: conn} do
    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => []
      })
      |> json_response(200)

    assert %{"total_cost" => 0} = res 
  end

    test "[GR1,SR1,GR1,GR1,CF1] basket", %{conn: conn} do
    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => ~w(GR1 SR1 GR1 GR1 CF1)
      })
      |> json_response(200)

    assert %{"total_cost" => 22.45} = res
  end

  test "[SR1,SR1,GR1,SR1] basket", %{conn: conn} do
    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => ~w(SR1 SR1 GR1 SR1)
      })
      |> json_response(200)

    assert %{"total_cost" => 16.61} = res
  end

    test "[GR1,GR1] basket", %{conn: conn} do
    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => ~w(GR1 GR1)
      })
      |> json_response(200)

    assert %{"total_cost" => 3.11} = res
  end


      test "[GR1,CF1,SR1,CF1,CF1] basket", %{conn: conn} do
    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => ~w(GR1 CF1 SR1 CF1 CF1)
      })
      |> json_response(200)

    assert %{"total_cost" => 30.57} = res
  end
  
end
