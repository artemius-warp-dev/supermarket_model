defmodule MessageBrokerIntTest do
  use ExUnit.Case, async: true

  import Mox
  defmock(ClusterDiscoveryMock, for: ClusterDiscoveryBehaviour)

  setup do
    Application.put_env(:message_broker, :basket_manager, BasketManager)
    :ok

    on_exit(fn ->
      Application.put_env(:message_broker, :basket_manager, BasketManagerMock)
    end)
  end

  test "simulate access from 3 users from one supermarket" do
    test_data = [
      {"user_1", "sp1", ~w(GR1 SR1 GR1 GR1 CF1)},
      {"user_2", "sp1", ~w(SR1 SR1 GR1 SR1)},
      {"user_3", "sp1", ~w(GR1 CF1 SR1 CF1 CF1)}
    ]

    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

    Task.async_stream(test_data, fn {user_id, super_market, basket} ->
      MessageBroker.route_request(super_market, user_id, basket)
    end)
    |> Enum.map(fn res ->
      assert {:ok, {:ok, %{total_cost: cost}}} = res
      assert cost in [22.45, 16.61, 30.57]
    end)
  end

  test "simulate access from 3 users from 3 supermarkes" do
    test_data = [
      {"user_1", "sp1", ~w(GR1 SR1 GR1 GR1 CF1)},
      {"user_2", "sp2", ~w(SR1 SR1 GR1 SR1)},
      {"user_3", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)}
    ]

    ClusterDiscoveryMock
    |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

    Task.async_stream(test_data, fn {user_id, super_market, basket} ->
      MessageBroker.route_request(super_market, user_id, basket)
    end)
    |> Enum.map(fn res ->
      assert {:ok, {:ok, %{total_cost: cost}}} = res
      assert cost in [22.45, 16.61, 30.57]
    end)
  end

  test "simulate acess from 10 users from 3 supermarkets" do
       test_data = [
      {"user_1", "sp1", ~w(GR1 SR1 GR1 GR1 CF1)},
      {"user_2", "sp2", ~w(SR1 SR1 GR1 SR1)},
      {"user_3", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_4", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_5", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_6", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_7", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_8", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_9", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)},
      {"user_10", "sp3", ~w(GR1 CF1 SR1 CF1 CF1)}
    ]

    ClusterDiscoveryMock
    |> expect(:get_nodes, 10, fn -> [:node1, :node2, :node3] end)

    Task.async_stream(test_data, fn {user_id, super_market, basket} ->
      MessageBroker.route_request(super_market, user_id, basket)
    end)
    |> Enum.map(fn res ->
      assert {:ok, {:ok, %{total_cost: cost}}} = res
      assert cost in [22.45, 16.61, 30.57]
    end)
    |> Enum.count()
    |> tap(fn count ->
      assert count == length(test_data)
    end)
  end
end
