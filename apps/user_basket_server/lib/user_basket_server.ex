defmodule UserBasketServer do
  require Logger
  use GenServer

  @moduledoc """
  A server that processes a user's basket by splitting it into product groups.
  """

  def start_link({user_id, basket, parent_server}) do
    name = generate_unique_key(user_id, parent_server) |> via_tuple()
    name_for_logs = "#{parent_server}_user_basket_server_#{user_id}"
    state = %{name: name_for_logs, basket: basket, user: user_id}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def init(state) do
    Logger.info("UserBasketServer started: #{inspect(state.name)} for user: #{state.user}")
    {:ok, state}
  end

  @impl true
  def handle_call(:process_basket, _from, state) do
    state.basket
    |> split_by_product()
    |> process_product_groups(state.name)
    |> handle_processing_results(state)
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("UserBasketServer: #{inspect(state.name)} stopped because of #{inspect(reason)}")

    :ok
  end

  defp process_product_groups(product_groups, name) do
    Task.Supervisor.async_stream(
      UserBasketServer.TaskSupervisor,
      product_groups,
      fn {product_type, items} ->
        {product_type, process_product_group(product_type, items, name)}
      end,
      max_concurrency: System.schedulers_online(),
      on_timeout: :exit
    )
    |> Enum.reduce_while(%{}, &reduce_group_results/2)
  end

  defp reduce_group_results({:ok, {product_type, result}}, acc) do
    {:cont, Map.put(acc, product_type, result)}
  end

  defp reduce_group_results({:error, reason}, _acc) do
    Logger.error("Product server error: #{inspect(reason)}")
    {:halt, {:error, reason}}
  end

  defp reduce_group_results(unhandled, _acc) do
    Logger.error("Unexpected error with reason: #{inspect(unhandled)}")
    {:halt, {:error, :product_server_error}}
  end

  defp handle_processing_results({:error, reason} = err, state) do
    Logger.error("Failed to process product groups: #{inspect(reason)}")
    {:stop, :normal, err, Map.put(state, :results, err)}
  end

  defp handle_processing_results(results, state) do
    {:stop, :normal, results, Map.put(state, :results, results)}
  end

  defp generate_unique_key(parent_server, user_id) do
    "#{parent_server}_user_basket_server_#{user_id}_#{:os.system_time(:millisecond)}"
  end

  defp via_tuple(unique_key), do: {:via, Registry, {UserBasketServerRegistry, unique_key}}

  defp split_by_product(basket) do
    Enum.group_by(basket, & &1)
  end

  defp process_product_group(product_type, items, parent_server) do
    {:ok, pid} = ProductDynamicSupervisor.start_product_server(product_type, items, parent_server)

    task =
      Task.Supervisor.async_nolink(UserBasketServer.TaskSupervisor, fn ->
        GenServer.call(pid, :calculate_cost)
      end)

    case Task.yield(task) || Task.shutdown(task) do
      {:ok, result} ->
        result

      nil ->
        {:error, :timeout}

      {:exit, reason} ->
        Logger.error("Unexpected error in the product server: #{inspect(reason)}")
        {:error, :product_server_error}
    end
  end
end
