defmodule GPS.Main do
  def start(numNodes \\ 1000, topology \\ :full, algorithm \\ :gossip) do
    time = System.monotonic_time(:millisecond)
    nodes = start_processing(numNodes)
    GPS.Topologies.build_topologies(nodes, topology)
    # Enum.each(nodes, fn pid -> print_output(pid) end)
    {:ok, pid} = GPS.GossipDriver.start_link(System.monotonic_time(:millisecond), nodes)
    GPS.GossipDriver.begin(pid)
    check_convergence(nodes, time)
  end

  defp start_processing(numNodes) do
    Enum.map(1..numNodes, fn _ ->
      GPS.NodeSupervisor.start_worker()
    end)
  end

  def check_convergence(nodes_list, start_time) do
    nodes_list = Enum.filter(nodes_list, fn pid -> GPS.NodeWorker.check_active(pid) end)
    # IO.puts(start_time)

    if(length(nodes_list) < 1) do
      IO.puts("Time ")
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.inspect(time_taken)
      System.halt(0)
    else
      check_convergence(nodes_list, start_time)
    end
  end

  defp print_output(pid) do
    # IO.inspect(pid, label: "pid")
    neighbors = GenServer.call(pid, {:fetch_neighbors}, :infinity)
    IO.puts(length(neighbors))
    # pid
    # |> GenServer.call({:fetch_neighbors}, :infinity)
    # |> Enum.map(fn neighbor -> IO.inspect(neighbor) end)
  end
end
