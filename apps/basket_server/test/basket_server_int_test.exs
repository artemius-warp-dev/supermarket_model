defmodule BasketServerIntTest do
  use ExUnit.Case

  setup do
    server_name = "basket_server_node1"
    {:ok, pid} = BasketServer.start_link(name: server_name)

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

    %{pid: pid, server_name: server_name}
  end

  test "combined basket for [GR1,SR1,GR1,GR1,CF]", %{server_name: server_name} do
    user_id = "user_1"
    basket = ["GR1", "SR1", "GR1", "GR1", "CF1"]
    super_market = "sp3"
    assert {:ok, result} = BasketServer.process_basket(server_name, super_market, user_id, basket)

    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 22.45
  end

  test "combined basket for [GR1,GR1]", %{server_name: server_name} do
    user_id = "user_1"
    basket = ["GR1", "GR1"]
    super_market = "sp3"
    assert {:ok, result} = BasketServer.process_basket(server_name, super_market, user_id, basket)

    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 3.11
  end

  test "combined basket for [SR1,SR1,GR1,SR1]", %{server_name: server_name} do
    user_id = "user_1"
    basket = ["SR1", "SR1", "GR1", "SR1"]
    super_market = "sp3"
    assert {:ok, result} = BasketServer.process_basket(server_name, super_market, user_id, basket)

    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 16.61
  end

  test "combined basket for [GR1,CF1,SR1,CF1,CF1]", %{server_name: server_name} do
    user_id = "user_1"
    basket = ["GR1", "CF1", "SR1", "CF1", "CF1"]
    super_market = "sp3"
    assert {:ok, result} = BasketServer.process_basket(server_name, super_market, user_id, basket)
    total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
    assert total_sum == 30.57
  end

  test "crash user server", %{server_name: server_name} do
    strategies = Application.get_env(:product_manager, :strategies)

    Application.put_env(
      :product_manager,
      :strategies,
      Map.put(strategies, :GR1_test, %{module: GR1TestStrategy, price: 1123})
    )

    basket = ~w(GR1_test GR1_test GR1_test) |> Stream.cycle() |> Enum.take(20)

    task =
      Task.async(fn ->
        BasketServer.process_basket(server_name, "sp1", "user_id", basket)
      end)

    user_superviser_pid = Process.whereis(UserDynamicSupervisor)
    {:ok, user_server_pid} = ServerTestHelpers.fetch_child_pid(user_superviser_pid)

    Process.exit(user_server_pid, :kill)
    assert {:error, _} = Task.await(task)
  end

  test "crash product's server", %{server_name: server_name} do
    strategy_path = "../product_manager/test/support/strategies/new/crash_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)

    basket = ~w(crash GR1_test GR1_test) |> Stream.cycle() |> Enum.take(10)

    task =
      Task.async(fn ->
        BasketServer.process_basket(server_name, "sp1", "user_id", basket)
      end)

    assert {:error, _} = Task.await(task)
  end

  test "combination of user and product servers crash", %{server_name: server_name} do
    strategy_path = "../product_manager/test/support/strategies/new/crash_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)

    test_data = [
      {"user_1", "sp1", ~w(crash)},
      {"user_2", "sp2", ~w(SR1 SR1 GR1_test SR1)},
      {"user_3", "sp3", ~w(GR1_test CF1 SR1 CF1 GR1_test)},
      {"user_4", "sp1", ~w(GR1_test GR1_test CF1 GR1_test GR1_test CF1)}
    ]

    task =
      Task.async(fn ->
        Task.async_stream(
          test_data,
          fn {user_id, super_market, basket} ->
            BasketServer.process_basket(server_name, super_market, user_id, basket)
          end
        )
        |> Enum.map(fn {:ok, res} -> res end)
      end)

    user_superviser_pid = Process.whereis(UserDynamicSupervisor)
    Process.sleep(1000)
    {:ok, user_server_pid} = ServerTestHelpers.fetch_child_pid(user_superviser_pid)

    Process.exit(user_server_pid, :kill)
    res = Task.await(task) |> Enum.filter(fn {atom, _res} -> atom == :error end) |> Enum.sort()

    assert [error: :product_server_error, error: :user_server_error] = res
  end
end
