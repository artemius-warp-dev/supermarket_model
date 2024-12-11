defmodule BasketManager.BasketServerSupervisor do
  use DynamicSupervisor

  alias BasketManager.PubSub

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ## Start a Basket Server
  def start_server(partition, supermarket_id) do
    spec = {BasketManager.BasketServer, {partition, supermarket_id}}
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, pid} ->
        PubSub.broadcast({:start_server, partition, supermarket_id})
        {:ok, pid}

      error ->
        error
    end
  end

  ## Shutdown a Basket Server
  def shutdown_basket_server(partition) do
    case Registry.lookup(BasketRegistry, partition) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        PubSub.broadcast({:shutdown_server, partition})
        {:ok, :shutdown}

      [] ->
        {:error, :not_found}
    end
  end

  ## Handle incoming PubSub events
  def handle_event({:start_server, partition, supermarket_id}) do
    spec = {BasketManager.BasketServer, {partition, supermarket_id}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def handle_event({:shutdown_server, partition}) do
    case Registry.lookup(BasketRegistry, partition) do
      [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      [] -> :ok
    end
  end
end
