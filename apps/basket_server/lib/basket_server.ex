defmodule BasketServer do
  @moduledoc """
  A server that manages user-specific basket processing.
  """
  require Logger

  use GenServer

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, %{global_name: name}, name: {:global, name})
  end

  def process_basket(_super_market, _user_id, nil) do
    {:error, :invalid_child_spec}
  end

  def process_basket(server_name, super_market, user_id, basket) do
    GenServer.call({:global, server_name}, {:process_basket, super_market, user_id, basket})
  end

  @impl true
  def init(state) do
    Logger.info("BasketServer: #{state.global_name} started")
    {:ok, state}
  end

  @impl true
  def handle_call({:process_basket, _supermarket_id, user_id, basket}, _from, state) do
    {:ok, user_server} =
      UserDynamicSupervisor.start_user_basket(user_id, basket, state.global_name)

    task =
      Task.Supervisor.async_nolink(BasketServer.TaskSupervisor, fn ->
        GenServer.call(user_server, :process_basket)
      end)

    response =
      case Task.yield(task) || Task.shutdown(task) do
        {:ok, {:error, reason}} ->
          {:error, reason}

        {:ok, result} ->
          process_result(result)

        nil ->
          {:error, :timeout}

        err ->
          Logger.error("Unexpected error: #{inspect(err)}")
          {:error, :user_server_error}
      end

    {:reply, response, Map.put(state, user_id, response)}
  end

  @impl true
  def terminate(reason, state) do
    Logger.info(
      "BasketServer: #{inspect(state.global_name)} stopped because of #{inspect(reason)}"
    )

    :ok
  end

  defp process_result(result) do
    Enum.reduce_while(result, 0, fn
      {_, {:error, reason}}, _ ->
        {:halt, {:error, reason}}

      {_, value}, acc ->
        {:cont, acc + value}
    end)
    |> case do
      {:error, reason} ->
        {:error, reason}

     res when is_number(res) ->
        {:ok, %{total_cost: res}}
    end
  end
end
