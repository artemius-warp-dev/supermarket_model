defmodule BasketServer.UserBasketServerTest do
  use ExUnit.Case, async: true

  alias UserBasketServer

  setup do
    Application.put_env(:product_manager, :strategies, %{
      GR1_test: %{module: ProductManager.GR1TestStrategy, price: 311, amount: 0},
      SR1_test: %{module: ProductManager.SR1TestStrategy, price: 500, amount: 0},
      CF1_test: %{module: ProductManager.CF1TestStrategy, price: 1123}
    })

    user_id = "user_123"

    basket =
      ~w(GR1_test SR1_test GR1_test GR1_test CF1_test) |> Stream.cycle() |> Enum.take(10_00)

    parent_server = "basket_server_node3"

    {:ok, pid} =
      UserBasketServer.start_link({user_id, basket, parent_server})

    %{pid: pid, basket: basket, user_id: user_id}
  end

  test "processes items and calculates totals", %{pid: pid, basket: basket} do
    result = GenServer.call(pid, :process_basket)
    assert %{fruit: 20, vegetable: 10} = result
  end

  test "check the product server crash", %{pid: pid, basket: basket} do
    Process.flag(:trap_exit, true)
    GenServer.call(pid, :get_state)
    product_superviser_pid = Process.whereis(ProductDynamicSupervisor)

    task =
      Task.async(fn ->
        GenServer.call(pid, :process_basket)
      end)

    Process.sleep(100)

    [{_, product_srv, _, _}, _, _] =
      Supervisor.which_children(product_superviser_pid)

    Process.exit(product_srv, :simulate_crash)

    assert {:error, :unhandled_case} = Task.await(task)
  end

  test "check the product server timeout", state do
    Process.flag(:trap_exit, true)
    GenServer.call(state.pid, :get_state)

    Task.async(fn ->
      GenServer.call(state.pid, :process_basket, 300)
    end)

    receive do
      {:EXIT, _, reason} -> assert {:timeout, _} = reason
    end
  end

  # TODO
  # test "returns state correctly", %{pid: pid, basket: basket, user_id: user_id} do
  #   state = GenServer.call(pid, :get_state)
  #   assert state == %{user_id: user_id, basket: basket, processed: false}
  # end
end
