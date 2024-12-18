defmodule ProductServer.Application do
  @moduledoc """
    Registry and Supervisor for Product server
  """
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ProductServerRegistry},
      {Task.Supervisor, name: ProductServer.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: ProductServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
