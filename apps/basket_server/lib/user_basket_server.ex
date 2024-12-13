defmodule UserBasketServer do
  require Logger
  use GenServer

  @moduledoc """
  A server that processes a user's basket by splitting it into product groups.
  """

  def start_link({user_id, basket, parent_server}) do
    name = via_atom(user_id, parent_server)
    state = %{name: name, basket: basket, user: user_id}
    GenServer.start_link(__MODULE__, state, name: name)
  end

  @impl true
  def init(state) do
    Logger.info("UserBasketServer started: #{inspect(state.name)} for user: #{state.user}")
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  @impl true
  def handle_call(:process_basket, _from, state) do
    product_groups = split_by_product(state.basket)

    product_groups
    |> Task.async_stream(
      fn {product_type, items} ->
        {product_type, process_product_group(product_type, items, state.name)}
      end,
    max_concurrency: System.schedulers_online(),
      timeout: 10_000,
      on_timeout: :exit
    )
    |> Enum.reduce_while(%{}, fn
      {:ok, {product_type, result}}, acc ->
        {:cont, Map.put(acc, product_type, result)}

      {:error, reason}, _acc ->
        Logger.error("Product server error: #{inspect(reason)}")
        {:halt, {:error, reason}}

      unhandled, _acc ->
        Logger.error("Unexpected error with reason: #{inspect(unhandled)}")
        {:halt, {:error, :unhandled_case}}
    end)
    |> case do
      {:error, reason} = err ->
        Logger.error("Failed to process product groups: #{inspect(reason)}")
        {:stop, :normal, err, Map.put(state, :results, err)}

      results ->
        {:stop, :normal, results, Map.put(state, :results, results)}
    end
  end

  def handle_call(:get_state, _from, state) do
    IO.inspect(state)
    {:reply, state, state}
  end

  @impl true
  def terminate(reason, state) do
    IO.inspect({"TERMINATE", state})
    Logger.info("UserBasketServer: #{inspect(state.name)} stopped because of #{inspect(reason)}")

    :ok
  end

  # TODO use regestry
  defp via_atom(user_id, parent_server),
    do: "#{parent_server}_#_user_basket_server_#{user_id}" |> String.to_atom()

  defp split_by_product(basket) do
    # TODO short version
    Enum.group_by(basket, fn product -> product end)
  end

  defp process_product_group(product_type, items, parent_server) do
    #Process.sleep(3000)
    {:ok, pid} = ProductDynamicSupervisor.start_product_server(product_type, items, parent_server)
    GenServer.call(pid, :calculate_cost, 10_000)
  end
end
