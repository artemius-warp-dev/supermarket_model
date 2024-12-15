defmodule UserDynamicSupervisor do
  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_user_basket(user_id, basket, parent_server) do
    child_spec = %{
      id: UserBasketServer,
      start: {UserBasketServer, :start_link, [{user_id, basket, parent_server}]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
