defmodule BasketServer do
  use GenServer

  def start_link({partition, supermarket_id}) do
    GenServer.start_link(__MODULE__, %{partition: partition, supermarket_id: supermarket_id},
      name: via_tuple(partition)
    )
  end

  def via_tuple(partition), do: {:via, Registry, {BasketRegistry, partition}}

  # def process_basket(partition, supermarket_id, basket_id, items) do
  #   GenServer.call(via_tuple(partition), {:process_basket, supermarket_id, basket_id, items})
  # end

  def init(state) do
    {:ok, state}
  end

  # def handle_call({:process_basket, supermarket_id, basket_id, items}, _from, state) do
  #   basket_data = %{
  #     items: items,
  #     total: Enum.count(items)
  #   }

  #   BasketManager.SupermarketState.add_basket(supermarket_id, basket_id, basket_data)

  #   {:reply, %{basket_id: basket_id, total_items: basket_data.total}, state}
  # end

  def get_state(pid, sm_id) do
    #TODO fetch ets from MarketState
    GenServer.call(pid, {:get_state, sm_id})
  end

  def handle_call({:get_state, _sm_id}, _from, state) do
    {:reply, %{items: [], total: 0}, state}
  end
  


  #   def add_item(basket_id, item) do
  #   GenServer.call(via_tuple(basket_id), {:add_item, item})
  # end

  # def handle_call({:add_item, item}, _from, state) do
  #   {:reply, :ok, Map.update!(state, :items, &[item | &1])}
  # end
end
