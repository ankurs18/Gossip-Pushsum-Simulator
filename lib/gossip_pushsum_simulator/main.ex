defmodule GPS.Main do
  def start(
        num_nodes \\ 100,
        topology \\ :torus,
        algorithm \\ :gossip,
        convergance_percentage \\ 0.9
      ) do
    start_time = System.monotonic_time(:millisecond)
    # For 3D Torus, we are using the nearest perfect cube to the num of nodes entered
    num_nodes =
      case topology do
        :torus -> :math.pow(num_nodes, 1 / 3) |> round() |> :math.pow(3) |> round()
        :honeycomb -> :math.sqrt(num_nodes) |> round() |> :math.pow(2) |> round()
        _ -> num_nodes
      end

    case algorithm do
      :gossip ->
        nodes = initialize_nodes(algorithm, num_nodes)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology)
        # {:ok, pid} = GPS.Gossip.Driver.start_link(System.monotonic_time(:millisecond), nodes)
        begin_gossip(nodes, start_time)

      :push_sum ->
        nodes = initialize_nodes(algorithm, num_nodes, start_time)
        GPS.Topologies.build_topologies(num_nodes, nodes, topology)
        begin_pushsum(nodes, start_time)
    end
  end

  defp begin_gossip(nodes_list, start_time) do
    GPS.Gossip.Node.send_message(Enum.random(nodes_list), :rumor)
    check_convergence_new(nodes_list, start_time)
  end

  defp begin_pushsum(nodes_list, start_time) do
    GPS.PushSum.Node.send_message(Enum.random(nodes_list), 0, 0)
    check_convergence_new(nodes_list, start_time)
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

  def check_convergence_pushsum(nodes_list, start_time, convergance_num) do
    nodes_list = Enum.filter(nodes_list, fn pid -> GPS.PushSum.Node.check_active(pid) end)

    if(length(nodes_list) <= convergance_num) do
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      System.halt(0)
    else
      check_convergence_pushsum(nodes_list, start_time, convergance_num)
    end
  end

  def check_convergence_new(nodes_list, start_time) do
    nodes_list = Enum.filter(nodes_list, fn pid -> Process.alive?(pid) end)
    len = length(nodes_list)

    if(len <= 1) do
      IO.puts("nodes remaining=  #{len}")
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      System.halt(0)
    else
      check_convergence_new(nodes_list, start_time)
    end
  end

  def check_convergence(nodes_list, start_time, convergance_num) do
    nodes_list = Enum.filter(nodes_list, fn pid -> GPS.Gossip.Node.check_active(pid) end)
    len = length(nodes_list)
    IO.puts("nodes remaining=  #{len}")

    if(len <= convergance_num) do
      IO.puts("Time ")
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.inspect(time_taken)
      System.halt(0)
    else
      check_convergence(nodes_list, start_time, convergance_num)
    end
  end
end
