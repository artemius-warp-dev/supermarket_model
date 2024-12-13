defmodule BasketServerIntTest do
  use ExUnit.Case, async: true

  setup do
    # start_supervised(ProductDynamicSupervisor) |> IO.inspect()
    # start_supervised(UserDynamicSupervisor)
    server_name = "basket_server_node1"
    {:ok, pid} = BasketServer.start_link(name: server_name)
    %{pid: pid, server_name: server_name}
  end

  # test "combined basket for [GR1,SR1,GR1,GR1,CF]", %{server_name: server_name} do
  #   user_id = "user_1"
  #   basket = ["GR1", "SR1", "GR1", "GR1", "CF1"]
  #   super_market = "sp3"
  #   result = BasketServer.process_basket(server_name, super_market, user_id, basket)

  #   total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
  #   assert total_sum == 22.45
  # end

  # test "combined basket for [GR1,GR1]", %{server_name: server_name} do
  #   user_id = "user_1"
  #   basket = ["GR1", "GR1"]
  #   super_market = "sp3"
  #   result = BasketServer.process_basket(server_name, super_market, user_id, basket)

  #   total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
  #   assert total_sum == 3.11
  # end

  # test "combined basket for [SR1,SR1,GR1,SR1]", %{server_name: server_name} do
  #   user_id = "user_1"
  #   basket = ["SR1", "SR1", "GR1", "SR1"]
  #   super_market = "sp3"
  #   result = BasketServer.process_basket(server_name, super_market, user_id, basket)

  #   total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
  #   assert total_sum == 16.61
  # end

  # test "combined basket for [GR1,CF1,SR1,CF1,CF1]", %{server_name: server_name} do
  #   user_id = "user_1"
  #   basket = ["GR1", "CF1", "SR1", "CF1", "CF1"]
  #   super_market = "sp3"
  #   result = BasketServer.process_basket(server_name, super_market, user_id, basket)
  #   IO.inspect(result)
  #   total_sum = Enum.reduce(result, 0, fn {_, value}, acc -> acc + value end)
  #   assert total_sum == 30.57
  # end

  test "crash user server", %{server_name: server_name} do
    strategies = Application.get_env(:product_manager, :strategies)
    Process.flag(:trap_exit, true)

    Application.put_env(
      :product_manager,
      :strategies,
      Map.put(strategies, :GR1_test, %{module: ProductManager.GR1TestStrategy, price: 1123})
    )

    basket = ~w(GR1_test GR1_test GR1_test) |> Stream.cycle() |> Enum.take(1000)

    task =
      Task.async(fn ->
        BasketServer.process_basket(server_name, "sp1", "user_id", basket)
      end)

    Process.sleep(100)
    user_superviser_pid = Process.whereis(UserDynamicSupervisor)

    [{:undefined, user_server_pid, :worker, [UserBasketServer]}] =
      Supervisor.which_children(user_superviser_pid)

    Process.exit(user_server_pid, :kill)
    assert {:error, _} = Task.await(task)
  end

  test "crash product's server", %{server_name: server_name} do
    strategies = Application.get_env(:product_manager, :strategies)
    Process.flag(:trap_exit, true)

    Application.put_env(
      :product_manager,
      :strategies,
      Map.put(strategies, :GR1_test, %{module: ProductManager.GR1TestStrategy, price: 1123})
    )

    basket = ~w(GR1_test GR1_test GR1_test) |> Stream.cycle() |> Enum.take(1000)

    task =
      Task.async(fn ->
        BasketServer.process_basket(server_name, "sp1", "user_id", basket)
      end)

    Process.sleep(100)
    product_superviser_pid = Process.whereis(ProductDynamicSupervisor)

    [{:undefined, product_server_pid, :worker, [ProductServer]}] =
      Supervisor.which_children(product_superviser_pid)

    Process.exit(product_server_pid, :kill)
    assert {:error, _} = Task.await(task)
  end

  test "combination of user and product servers crash", %{server_name: server_name} do
    strategies = Application.get_env(:product_manager, :strategies)
    Process.flag(:trap_exit, true)

    Application.put_env(
      :product_manager,
      :strategies,
      Map.put(strategies, :GR1_test, %{module: ProductManager.GR1TestStrategy, price: 1123})
    )

    test_data = [
      {"user_1", "sp1", ~w(GR1_test GR1_test GR1_test)},
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

    Process.sleep(200)
    product_superviser_pid = Process.whereis(ProductDynamicSupervisor)

    [{:undefined, product_server_pid, :worker, [ProductServer]}] =
      Supervisor.which_children(product_superviser_pid)

    Process.exit(product_server_pid, :kill)
    user_superviser_pid = Process.whereis(UserDynamicSupervisor)
    Process.sleep(2000)

    [{:undefined, user_server_pid, :worker, [UserBasketServer]}] =
      Supervisor.which_children(user_superviser_pid)

    # Process.info(user_server_pid) |> IO.inspect()

    Process.exit(user_server_pid, :kill)
    res = Task.await(task) |> Enum.filter(fn {atom, _res} -> atom == :error end)

    assert [
             error: :unhandled_case,
             error: {:killed, _}
           ] = res
  end
end

# test_data = [
#    {"user_1", "sp1", ~w(GR1_test GR1_test GR1_test) |> Stream.cycle() |> Enum.take(1000)},
#    {"user_2", "sp2",
#     ~w(SR1 SR1 GR1 SR1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_3", "sp2",
#     ~w(GR1 CF1 SR1 CF1 CF1_test) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_4", "sp2",
#     ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_5", "sp1",
#     ~w(GR1 CF1 SR1 CF1 CF1_test) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_6", "sp3",
#     ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_1", "sp3",
#     ~w(GR1 CF1 SR1 CF1 CF1_test) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_3", "sp3",
#     ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_9", "sp3",
#     ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))},
#    {"user_10", "sp3",
#     ~w(GR1 CF1 SR1 CF1 CF1) |> Stream.cycle() |> Enum.take(:rand.uniform(10_000))}
#  ]
