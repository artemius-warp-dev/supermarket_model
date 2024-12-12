defmodule ClusterDiscoveryBehaviour do
  @moduledoc """
  Provides cluster node discovery functionality.
  """

  @callback get_nodes() :: [atom]
end

defmodule ClusterDiscovery do
  @behaviour ClusterDiscoveryBehaviour
  def get_nodes do
    :erlang.nodes()
  end
end
