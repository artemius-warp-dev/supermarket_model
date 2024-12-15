defmodule UserBasketServerTest do
  use ExUnit.Case

  alias UserBasketServer

  setup_all do
    StrategyLoader.load_strategies("../product_manager/test/support/strategies")
    :ok
  end

  setup do
    strategies = %{
      CF1: %{currency: :eur, module: CF1Strategy, price: 1123},
      CF1_test: %{currency: :eur, module: CF1TestStrategy, price: 500},
      GR1: %{currency: :eur, module: GR1Strategy, price: 311},
      GR1_test: %{currency: :eur, module: GR1TestStrategy, price: 500},
      MF1: %{currency: :eur, module: MF1Strategy, price: 500},
      SR1: %{currency: :eur, module: SR1Strategy, price: 500},
      SR1_test: %{currency: :eur, module: SR1TestStrategy, price: 500},
      crash: %{module: CrashStrategy}
    }

    Application.put_env(:product_manager, :strategies, strategies)
    start_supervised(UserDynamicSupervisor)
    start_supervised({Task.Supervisor, name: UserBasketServer.TaskSupervisor})
    start_supervised(ProductDynamicSupervisor)

    user_id = "user_123"

    basket =
      ~w(GR1 SR1 GR1 GR1 CF1)

    parent_server = "basket_server_node3"

    %{basket: basket, user_id: user_id, parent_server: parent_server}
  end

  test "processes items and calculates totals", state do
    {:ok, pid} =
      UserDynamicSupervisor.start_user_basket(state.user_id, state.basket, state.parent_server)

    result = GenServer.call(pid, :process_basket)
    assert %{"CF1" => 11.23, "GR1" => 6.22, "SR1" => 5.0} = result
  end

  test "check the product server crash", state do
    strategy_path = "../product_manager/test/support/strategies/new/crash_strategy.exs"
    assert :ok == StrategyLoader.load_strategy(strategy_path)

    basket =
      ~w(GR1 SR1 crash)

    {:ok, pid} =
      UserDynamicSupervisor.start_user_basket(state.user_id, basket, state.parent_server)


    task =
      Task.async(fn ->
        GenServer.call(pid, :process_basket)
      end)

    assert %{
             "GR1" => 3.11,
             "crash" => {:error, :product_server_error},
             "SR1" => 5.0
           } = Task.await(task)
  end

  test "check the product server timeout", state do
    Process.flag(:trap_exit, true)

    basket = ~w(GR1_test, SR1_test, CF1_test) |> Stream.cycle() |> Enum.take(100)

    {:ok, pid} =
      UserDynamicSupervisor.start_user_basket(state.user_id, basket, state.parent_server)

    GenServer.call(pid, :get_state)

    Task.async(fn ->
      GenServer.call(pid, :process_basket, 100)
    end)

    receive do
      {:EXIT, _, reason} -> assert {:timeout, _} = reason
    end
  end
end
