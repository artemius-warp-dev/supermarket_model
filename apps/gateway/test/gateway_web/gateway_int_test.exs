defmodule GatewayIntegrationTest do
  use GatewayWeb.ConnCase

  import Mox
  defmock(ClusterDiscoveryMock, for: ClusterDiscoveryBehaviour)

  setup do
    Application.put_env(:gateway, :message_broker, MessageBroker)
    Application.put_env(:message_broker, :basket_manager, BasketManager)

    strategies = %{
      CF1: %{currency: :eur, module: CF1Strategy, price: 1123},
      CF1_test: %{currency: :eur, module: CF1TestStrategy, price: 500},
      GR1: %{currency: :eur, module: GR1Strategy, price: 311},
      GR1_test: %{currency: :eur, module: GR1TestStrategy, price: 500},
      MF1: %{currency: :eur, module: MF1Strategy, price: 500},
      SR1: %{currency: :eur, module: SR1Strategy, price: 500},
      SR1_test: %{currency: :eur, module: SR1TestStrategy, price: 500}
    }

    Application.put_env(:product_manager, :strategies, strategies)

    :ok

    on_exit(fn ->
      Application.put_env(:gateway, :message_broker, MessageBrokerMock)
      Application.put_env(:message_broker, :basket_manager, BasketManagerMock)
      Application.put_env(:message_broker, :cluster_discovery, ClusterDiscoveryMock)
    end)
  end

  test "empty basket", %{conn: conn} do
    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

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
    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

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
    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

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
    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

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
    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

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

  test "to handle 10 requests concurrently", %{conn: conn} do
    test_data = [
      {"user_1", "sp1", ~w(GR1 GR1 GR1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_2", "sp2",
       ~w(SR1 SR1 GR1 SR1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_3", "sp2",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_4", "sp2",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_5", "sp1",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_6", "sp3",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_1", "sp3",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_3", "sp3",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_9", "sp3",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
      {"user_10", "sp3",
       ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))}
    ]

    ClusterDiscoveryMock
    |> expect(:get_nodes, length(test_data), fn -> [:node1, :node2, :node3] end)

    Task.async_stream(test_data, fn {user_id, super_market, basket} ->
      conn
      |> post("/api/basket", %{
        "supermarket_id" => super_market,
        "user_id" => user_id,
        "items" => basket
      })
      |> json_response(200)
    end)
    |> Enum.map(fn {:ok, res} ->
      assert %{"total_cost" => _cost} = res
    end)
  end

  @tag timeout: 500_000
  test "to handle 1_000_000 requests concurrently", %{conn: conn} do
    test_data =
      [
        {"user_1", "sp1", ~w(GR1 GR1 GR1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_2", "sp2",
         ~w(SR1 SR1 GR1 SR1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_3", "sp2",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_4", "sp2",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_5", "sp1",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_6", "sp3",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_1", "sp3",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_3", "sp3",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_9", "sp3",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
        {"user_10", "sp3",
         ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))}
      ]
      |> Stream.cycle()
      |> Enum.take(1_000_00)

    ClusterDiscoveryMock
    |> expect(:get_nodes, length(test_data), fn -> [:node1, :node2, :node3] end)

    Task.async_stream(test_data, fn {user_id, super_market, basket} ->
      conn
      |> post("/api/basket", %{
        "supermarket_id" => super_market,
        "user_id" => user_id,
        "items" => basket
      })
      |> json_response(200)
    end)
    |> Enum.map(fn {:ok, res} ->
      assert %{"total_cost" => _cost} = res
    end)
  end

  test "to handle combination of failures in child servers", %{conn: conn} do

    strategy_path = "../product_manager/test/support/strategies/new/crash_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)

    test_data =
      [
        {"user_1", "sp1", ~w(GR1_test GR1_test GR1_test)},
        {"user_2", "sp2", ~w(SR1 SR1 GR1 SR1)},
        {"user_3", "sp2", ~w(GR1 CF1 SR1 CF1 GR1_test)},
        {"user_4", "sp2", ~w(crash CF1 SR1 CF1 GR1_test)},
        {"user_5", "sp1", ~w(GR1 CF1 SR1 CF1 GR1_test)},
        {"user_6", "sp3", ~w(GR1 CF1 SR1 CF1 GR1_test)},
        {"user_1", "sp3", ~w(GR1 CF1 SR1 CF1 GR1_test)},
        {"user_3", "sp3", ~w(GR1 CF1 SR1 CF1 GR1_test)},
        {"user_9", "sp3", ~w(GR1 CF1 SR1 CF1 GR1_test)},
        {"user_10", "sp3", ~w(GR1 CF1 SR1 CF1 GR1_test)}
      ]

    ClusterDiscoveryMock
    |> expect(:get_nodes, length(test_data), fn -> [:node1, :node2, :node3] end)

    task =
      Task.async(fn ->
        Task.async_stream(test_data, fn {user_id, super_market, basket} ->
          response =
            conn
            |> post("/api/basket", %{
              "supermarket_id" => super_market,
              "user_id" => user_id,
              "items" => basket
            })

          case response.status do
            200 -> json_response(response, 200)
            400 -> json_response(response, 400)
          end
        end)
        |> Enum.map(&elem(&1, 1))
      end)

    product_superviser_pid = Process.whereis(ProductDynamicSupervisor)
    user_superviser_pid = Process.whereis(UserDynamicSupervisor)
    {:ok, product_server_pid} = ServerTestHelpers.fetch_child_pid(product_superviser_pid)

    Process.exit(product_server_pid, :kill)
    Process.sleep(1000)
    {:ok, user_server_pid} = ServerTestHelpers.fetch_child_pid(user_superviser_pid)
    Process.exit(user_server_pid, :kill)
    errors = Task.await(task) |> Enum.filter(&Map.has_key?(&1, "error"))

    expected_errors = [
      %{"error" => "user_server_error"},
      %{"error" => "product_server_error"}
    ]

    assert MapSet.new(errors) == MapSet.new(expected_errors)
  end

  test "to handle long timeout operations", %{conn: conn} do
    strategies = Application.get_env(:product_manager, :strategies)

    Application.put_env(
      :product_manager,
      :strategies,
      Map.put(strategies, :GR1_test, %{module: GR1TestStrategy, price: 1123})
    )

    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => ~w(GR1_test GR1_test) |> Stream.cycle() |> Enum.take(10_000)
      })
      |> json_response(400)

    assert %{"error" => "timeout"} = res
  end

  test "to handle missing product", %{conn: conn} do
    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

    res =
      conn
      |> post("/api/basket", %{
        "supermarket_id" => 1,
        "user_id" => 1,
        "items" => ~w(GR2)
      })
      |> json_response(400)

    assert %{"error" => "Strategy for product not found"} = res
  end
end
