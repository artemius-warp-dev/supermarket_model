defmodule ServerTestHelpers do
  def fetch_child_pid(supervisor, timeout \\ 5000, interval \\ 100) do
    start_time = System.monotonic_time(:millisecond)
    fetch_child_pid(supervisor, timeout, interval, start_time)
  end

  defp fetch_child_pid(supervisor, timeout, interval, start_time) do
    case Supervisor.which_children(supervisor) do
      [] ->
        Process.sleep(interval)

        if elapsed_time(start_time) >= timeout do
          {:error, :timeout}
        else
          fetch_child_pid(supervisor, timeout, interval, start_time)
        end

      [{_, pid, _, _} | _] ->
        {:ok, pid}
    end
  end

  defp elapsed_time(start_time) do
    System.monotonic_time(:millisecond) - start_time
  end
end
