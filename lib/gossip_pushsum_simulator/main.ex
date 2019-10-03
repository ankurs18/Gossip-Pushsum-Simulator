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
        begin_gossip(nodes, num_nodes, start_time, failure_percent)

      :push_sum ->
        nodes = initialize_nodes(algorithm, num_nodes, start_time)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology, algorithm)
        begin_pushsum(nodes, start_time, num_nodes, failure_percent)
    end
  end

  defp begin_gossip(nodes_list, num_nodes, start_time, failure_percent) do
    # num_failure_nodes = (failure_percent / 100 * length(nodes_list)) |> round()
    # IO.puts("failuer: #{num_failure_nodes}")

    nodes_list =
      if failure_percent > 0 do
        nodes_list -- kill_nodes(nodes_list, failure_percent)
      else
        nodes_list
      end

    GPS.Gossip.Node.send_message(Enum.random(nodes_list), :rumor)

    if failure_percent > 0 do
      check_convergence(nodes_list, start_time, num_nodes, num_nodes - length(nodes_list), 10000)
    else
      check_convergence(nodes_list, start_time, num_nodes, num_nodes - length(nodes_list))
    end
  end

  defp begin_pushsum(nodes_list, num_nodes, start_time, failure_percent) do
    nodes_list =
      if failure_percent > 0 do
        nodes_list -- kill_nodes(nodes_list, failure_percent)
      else
        nodes_list
      end

    num_failure_nodes = (failure_percent / 100 * length(nodes_list)) |> round()
    GPS.PushSum.Node.send_message(Enum.random(nodes_list), 0, 0)

    if failure_percent > 0 do
      check_convergence(nodes_list, start_time, num_nodes, num_nodes - length(nodes_list), 30000)
    else
      check_convergence(nodes_list, start_time, num_nodes, num_nodes - length(nodes_list))
    end
  end

  defp kill_nodes(nodes_list, failure_percent) do
    num_failure_nodes = (failure_percent / 100 * length(nodes_list)) |> round()
    IO.puts("#{num_failure_nodes}")

    killed_nodes =
      Enum.map(0..num_failure_nodes, fn _ ->
        unlucky_node = Enum.random(nodes_list)
        Process.exit(unlucky_node, :shutdown)
        unlucky_node
      end)

    Enum.uniq(killed_nodes)
  end

  def check_convergence(
        nodes_list,
        start_time,
        num_nodes,
        num_failure_nodes,
        timeout \\ 0,
        no_change_count \\ 0,
        initialize_time \\ 0
      ) do
    prev_length = length(nodes_list)
    nodes_list = Enum.filter(nodes_list, fn pid -> Process.alive?(pid) end)
    len = length(nodes_list)
    # IO.puts("nodes remaining=  #{len}")

    no_change_count = if len == prev_length, do: no_change_count + 1, else: 0
    # IO.puts("#{len} #{prev_length} no change: #{no_change_count}")
    initialize_time =
      cond do
        no_change_count == 1 -> System.monotonic_time(:millisecond)
        no_change_count > 1 -> initialize_time
        true -> 0
      end

    if(len <= 1) do
      IO.puts("nodes remaining=  #{len}")
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      IO.puts("Current convergence spread: #{num_nodes} #{num_failure_nodes} ")
      IO.puts("Current convergence spread: #{(num_nodes - num_failure_nodes) / num_nodes * 100}%")
      System.halt(0)
    else
      if initialize_time != 0 and timeout > 0 and no_change_count > 10 and
           System.monotonic_time(:millisecond) - initialize_time > timeout do
        IO.puts("#{System.monotonic_time(:millisecond)} - #{start_time} . #{timeout}")
        IO.puts("Application timeout")
        end_time = System.monotonic_time(:millisecond)
        time_taken = end_time - start_time
        IO.puts("Time taken: #{time_taken}")
        IO.puts("Current convergence spread: #{num_nodes} #{len}")

        IO.puts(
          "Current convergence spread: #{(num_nodes - len - num_failure_nodes) / num_nodes * 100}%"
        )

        System.halt(0)
      end

      check_convergence(
        nodes_list,
        start_time,
        num_nodes,
        num_failure_nodes,
        timeout,
        no_change_count,
        initialize_time
      )
    end
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
end
