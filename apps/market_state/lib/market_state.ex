defmodule MarketState do
  @ttl_ms 300_000 # 5 minutes TTL

  ## ETS Table Management

  # Initialize an ETS table for a supermarket
  def create_table(supermarket_id) do
    table_name = ets_table_name(supermarket_id)

    :ets.new(table_name, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true}
    ])
  end

  # Delete an ETS table for a supermarket
  def delete_table(supermarket_id) do
    table_name = ets_table_name(supermarket_id)
    :ets.delete(table_name)
  end

  # Generate ETS table name dynamically
  def ets_table_name(supermarket_id), do: :"supermarket_#{supermarket_id}_baskets"


  def store_state(supermarket_id, state_data) do
    :ok
  end

  def get_state(supermarket_id) do
    %{total_basket_count: 5, total_sales: 100}
  end
  

  ## Basket Operations

  # Add or update a basket
  def add_basket(supermarket_id, basket_id, basket_data) do
    table_name = ets_table_name(supermarket_id)
    :ets.insert(table_name, {basket_id, Map.put(basket_data, :timestamp, System.system_time(:millisecond))})
  end

  # Get a basket
  def get_basket(supermarket_id, basket_id) do
    table_name = ets_table_name(supermarket_id)

    case :ets.lookup(table_name, basket_id) do
      [{^basket_id, data}] -> {:ok, data}
      [] -> {:error, :not_found}
    end
  end

  # Remove a basket
  def remove_basket(supermarket_id, basket_id) do
    table_name = ets_table_name(supermarket_id)
    :ets.delete(table_name, basket_id)
  end

  # Cleanup expired baskets
  def cleanup(supermarket_id) do
    table_name = ets_table_name(supermarket_id)
    now = System.system_time(:millisecond)

    :ets.select_delete(table_name, [
      {{:"$1", :"$2"},
       [{:<, {:element, 2, :"$2", :timestamp}, now - @ttl_ms}],
       [true]}
    ])
  end
end
