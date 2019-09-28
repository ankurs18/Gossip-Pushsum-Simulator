defmodule GPS.Main do
  def start(numNodes \\ 1000, topology \\ :rand2D, algorithm \\ :gossip) do
    nodes = start_processing(numNodes)
    GPS.Topologies.build_topologies(nodes, topology)
    Enum.each(nodes, fn pid -> print_output(pid) end)
  end

  defp start_processing(numNodes) do
    Enum.map(1..numNodes, fn x ->
      GPS.NodeSupervisor.start_worker()
    end)
  end

  defp print_output(pid) do
    IO.inspect(pid, label: "pid")
    neighbors = GenServer.call(pid, {:fetch_neighbors}, :infinity)
    IO.puts(length(neighbors))
    # pid
    # |> GenServer.call({:fetch_neighbors}, :infinity)
    # |> Enum.map(fn neighbor -> IO.inspect(neighbor) end)
  end
end
