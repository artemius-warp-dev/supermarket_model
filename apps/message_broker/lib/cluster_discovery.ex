defmodule ClusterDiscoveryBehaviour do
  @moduledoc """
  Provides cluster node discovery functionality.
  """

  @callback get_nodes() :: [atom]
end

defmodule ClusterDiscovery do
  @moduledoc """
  Cluster for scalability BasketServers
  """
  @behaviour ClusterDiscoveryBehaviour
  def get_nodes do
    :erlang.nodes()
  end
end
