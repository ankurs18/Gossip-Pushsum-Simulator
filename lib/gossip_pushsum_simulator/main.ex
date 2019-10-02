defmodule GPS.Main do
  def start(
        num_nodes \\ 100,
        topology \\ :torus,
        algorithm \\ :gossip,
        failure_percent \\ 0
      ) do
    start_time = System.monotonic_time(:millisecond)
    # For 3D Torus, we are using the nearest perfect cube to the num of nodes entered
    # For Honeycomb,  we are using the nearest perfect square to the num of nodes entered
    num_nodes =
      case topology do
        :torus -> :math.pow(num_nodes, 1 / 3) |> round() |> :math.pow(3) |> round()
        :honeycomb -> :math.sqrt(num_nodes) |> round() |> :math.pow(2) |> round()
        :randhoneycomb -> :math.sqrt(num_nodes) |> round() |> :math.pow(2) |> round()
        _ -> num_nodes
      end

    case algorithm do
      :gossip ->
        nodes = initialize_nodes(algorithm, num_nodes)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology, algorithm)
        begin_gossip(nodes, start_time, failure_percent)

      :push_sum ->
        nodes = initialize_nodes(algorithm, num_nodes, start_time)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology, algorithm)
        begin_pushsum(nodes, start_time, failure_percent)
    end
  end

  defp begin_gossip(nodes_list, start_time, failure_percent) do
    nodes_list =
      if failure_percent > 0, do: kill_nodes(nodes_list, failure_percent), else: nodes_list

    IO.puts("lenght #{length(nodes_list)}")
    GPS.Gossip.Node.send_message(Enum.random(nodes_list), :rumor)
    check_convergence(nodes_list, start_time)
  end

  defp begin_pushsum(nodes_list, start_time, failure_percent) do
    nodes_list =
      if failure_percent > 0, do: kill_nodes(nodes_list, failure_percent), else: nodes_list

    GPS.PushSum.Node.send_message(Enum.random(nodes_list), 0, 0)
    check_convergence(nodes_list, start_time)
  end

  defp kill_nodes(nodes_list, failure_percent) do
    num_failure_nodes = (failure_percent / 100 * length(nodes_list)) |> round()
    IO.puts("#{num_failure_nodes}")

    killed_nodes =
      Enum.map(1..num_failure_nodes, fn _ ->
        unlucky_node = Enum.random(nodes_list)
        Process.exit(unlucky_node, :normal)
        unlucky_node
      end)

    nodes_list -- killed_nodes
  end

  defp initialize_nodes(:gossip, num_nodes) do
    Enum.map(1..num_nodes, fn _ ->
      GPS.NodeSupervisor.start_worker(:gossip)
    end)
  end

  defp initialize_nodes(:push_sum, num_nodes, start_time) do
    Enum.map(1..num_nodes, fn i ->
      GPS.NodeSupervisor.start_worker(:push_sum, i, start_time)
    end)
  end

  def check_convergence(nodes_list, start_time) do
    nodes_list = Enum.filter(nodes_list, fn pid -> Process.alive?(pid) end)
    len = length(nodes_list)
    # IO.puts("nodes remaining=  #{len}")
    if(len <= 1) do
      IO.puts("nodes remaining=  #{len}")
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      System.halt(0)
    else
      check_convergence(nodes_list, start_time)
    end
  end
end
