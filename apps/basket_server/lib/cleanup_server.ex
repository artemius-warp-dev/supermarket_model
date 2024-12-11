defmodule CleanupServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_cleanup()
    {:ok, state}
  end

  # def handle_info(:cleanup, state) do
  #   for {supermarket_id, _pid} <- Registry.lookup(SupermarketRegistry) do
  #      MarketState.cleanup(supermarket_id)
  #   end

  #   schedule_cleanup()
  #   {:noreply, state}
  # end

  defp schedule_cleanup() do
    Process.send_after(self(), :cleanup, 60_000)
  end
end
