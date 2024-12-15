defmodule ProductServerTest do
  use ExUnit.Case

  alias ProductServer

  setup_all do
    StrategyLoader.load_strategies("../product_manager/test/support/strategies")
    :ok
  end

  setup do
    user_id = "user_1"
    product_type = "GR1"
    items = ["GR1", "GR1", "GR1"]
    parent_server = "basket_server_node1_#_user_basket_server_user_1"

    strategies = %{
      CF1: %{currency: :eur, module: CF1Strategy, price: 1123},
      CF1_test: %{currency: :eur, module: CF1TestStrategy, price: 500},
      GR1: %{currency: :eur, module: GR1Strategy, price: 311},
      GR1_test: %{currency: :eur, module: GR1TestStrategy, price: 500},
      MF1: %{currency: :eur, module: MF1Strategy, price: 500},
      SR1: %{currency: :eur, module: SR1Strategy, price: 500},
      SR1_test: %{currency: :eur, module: SR1TestStrategy, price: 500}
    }

    start_supervised(ProductDynamicSupervisor)

    Application.put_env(:product_manager, :strategies, strategies)
    %{items: items, product_type: product_type, user_id: user_id, parent_server: parent_server}
  end

  test "calculates total cost for products", state do
    {:ok, pid} =
      ProductDynamicSupervisor.start_product_server(
        state.product_type,
        state.items,
        state.parent_server
      )

    total_price = GenServer.call(pid, :calculate_cost)
    assert total_price == 6.22
  end

  test "stops after processing items", state do
    {:ok, pid} =
      ProductDynamicSupervisor.start_product_server(
        state.product_type,
        state.items,
        state.parent_server
      )

    _total_price = GenServer.call(pid, :calculate_cost)
    refute Process.alive?(pid)
  end

  test "server crash during processing cause timeout and recover", state do
    items = Stream.cycle(["GR1", "GR1", "GR1"]) |> Enum.take(10_000)
    Process.flag(:trap_exit, true)

    {:ok, pid} =
      ProductDynamicSupervisor.start_product_server(
        state.product_type,
        items,
        state.parent_server
      )

    spawn_link(fn ->
      GenServer.call(pid, {:sleep, 5000}, 100)
    end)

    receive do
      {:EXIT, _, reason} -> assert {:timeout, _} = reason
    end

    Process.sleep(300)

    assert Process.alive?(pid) == true
    assert Map.get(GenServer.call(pid, :get_state), :items) |> length() == 10_000
    assert GenServer.call(pid, :calculate_cost) == 15_550.0
  end
end
