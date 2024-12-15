defmodule MessageBrokerTest do
  use ExUnit.Case
  import Mox

 
  describe "find_basket_server/1" do
    test "maps partition to a node in the cluster" do
      ClusterDiscoveryMock
      |> expect(:get_nodes, 3, fn -> [:node1, :node2, :node3] end)

      assert MessageBroker.find_basket_server(0) == :basket_server_node1
      assert MessageBroker.find_basket_server(1) == :basket_server_node2
      assert MessageBroker.find_basket_server(2) == :basket_server_node3
    end

    test "handles cases with fewer nodes than partitions" do
      ClusterDiscoveryMock
      |> expect(:get_nodes, 3, fn -> [:node1, :node2] end)

      assert MessageBroker.find_basket_server(0) == :basket_server_node1
      assert MessageBroker.find_basket_server(1) == :basket_server_node2
      assert MessageBroker.find_basket_server(2) == :basket_server_node1
    end
  end

  describe "route_request/3" do
    test "routes request successfully" do
      super_market = "supermarket_1"
      user = "user_1"
      _basket_server = :erlang.phash2({super_market, user}, 3)

      BasketManagerMock
      |> expect(:handle_request, fn _basket_server, _super_marker, _user, _items ->
        {:ok, %{total: 42}}
      end)

      ClusterDiscoveryMock
      |> expect(:get_nodes, fn -> [:node1, :node2, :node3] end)

      response =
        MessageBroker.route_request("supermarket_1", "user_1", [
          %{"product_id" => "p1", "quantity" => 2}
        ])

      assert {:ok, %{total: 42}} == response
    end

    test "handles errors from route request" do
      BasketManagerMock
      |> expect(:handle_request, fn :basket_server_node2, "supermarket_1", "user_1", _items ->
        {:error, "some error"}
      end)

      ClusterDiscoveryMock
      |> expect(:get_nodes, fn -> [:node1, :node2, :node3] end)

      response =
        MessageBroker.route_request("supermarket_1", "user_1", [
          %{"product_id" => "p1", "quantity" => 2}
        ])

      assert {:error, "some error"} == response
    end
  end
end
