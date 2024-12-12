defmodule BasketServer do
  @moduledoc """
  A server that manages user-specific basket processing.
  """

  use GenServer
  # use Cluster.Node, topologies: [my_cluster: [hosts: :peer]]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def process_basket(user_id, nil) do
    {:error, :invalid_child_spec}
  end

  def process_basket(user_id, basket) do
    GenServer.call(__MODULE__, {:process_basket, user_id, basket})
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:process_basket, user_id, basket}, _from, state) do
    {:ok, user_server} =
      UserDynamicSupervisor.start_user_basket(user_id, basket) |> IO.inspect()

    result = GenServer.call(user_server, :process_basket)
    {:reply, result, Map.put(state, user_id, result)}
  end
end
