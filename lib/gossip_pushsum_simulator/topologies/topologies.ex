defmodule GPS.Topologies do
  def build_topologies(list_nodes, topology_type) do
    case topology_type do
      :line -> build_line_topology(list_nodes)
      :full -> build_full_topology(list_nodes)
      :rand2D -> build_rand2D_topology(list_nodes)
    end
  end

  defp random_coordinates_generator(elem, map) do
    Map.put(map, elem, [:rand.uniform(), :rand.uniform()])
  end

  def build_rand2D_topology(list_nodes) do
    #IO.inspect(list_nodes)
    coordinates_map = Enum.reduce(list_nodes, %{}, &random_coordinates_generator/2)
    #IO.inspect(coordinates_map)

    Enum.each(coordinates_map, fn {k, v} ->
      [x1, y1] = v

      for x <- Map.keys(coordinates_map) -- [k] do
        [x2, y2] = Map.get(coordinates_map, x)

        if :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2)) <= 0.1 do
          GenServer.cast(k, {:add_neighbor, x})
        end
      end
    end)
  end

  def build_full_topology(list_nodes) do
    for elem <- list_nodes do
      GenServer.cast(elem, {:set_neighbors, list_nodes -- [elem]})
    end
  end

  def build_line_topology(list_nodes) do
    num_nodes = length(list_nodes)

    for i <- 0..(num_nodes - 1) do
      cond do
        i == 0 -> line_topology_helper(list_nodes, [i, i + 1])
        i == num_nodes - 1 -> line_topology_helper(list_nodes, [i, i - 1])
        true -> line_topology_helper(list_nodes, [i, i - 1, i + 1])
      end
    end
  end

  defp line_topology_helper(list_nodes, neighborhood) do
    [self_index | neighbors_index] = neighborhood

    neighbors =
      for i <- neighbors_index do
        Enum.at(list_nodes, i)
      end

    GenServer.cast(Enum.at(list_nodes, self_index), {:set_neighbors, neighbors})
  end
end
