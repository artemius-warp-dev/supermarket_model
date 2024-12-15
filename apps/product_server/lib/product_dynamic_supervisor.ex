defmodule ProductDynamicSupervisor do
  @moduledoc """
  Supervisor for Product server tasks
  """
  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_product_server(product_type, items, parent_server) do
    child_spec = %{
      id: ProductServer,
      start: {ProductServer, :start_link, [{product_type, items, parent_server}]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
