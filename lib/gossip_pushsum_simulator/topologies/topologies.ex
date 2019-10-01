defmodule GPS.Topologies do
  def build_topologies(num_nodes, list_nodes, topology_type) do
    case topology_type do
      :line -> build_line_topology(list_nodes)
      :full -> build_full_topology(list_nodes)
      :rand2D -> build_rand2D_topology(list_nodes)
      :torus -> build_3Dtorus_topology(num_nodes, list_nodes)
      :honeycomb -> build_honeycomb_topology(num_nodes, list_nodes, false)
      :randhoneycomb -> build_honeycomb_topology(num_nodes, list_nodes, true)
    end
  end

  def build_3Dtorus_topology(num_nodes, list_nodes) do
    y = num_nodes |> :math.pow(1 / 3) |> round()
    z = y * y

    for i <- 1..(z * y) do
      rem_iz = rem(i, z)
      rem_iy = rem(i, y)
      z1 = if i <= z, do: i + z * (y - 1), else: i - z
      z2 = if i > z * (y - 1), do: i - z * (y - 1), else: i + z

      cond do
        i == 1 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i + y - 1,
              i + 1,
              i + y,
              i + y * (y - 1),
              z2,
              z1
            ],
            false
          )

        (rem_iz > y * (y - 1) or rem_iz == 0) and rem_iy == 1 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i + y - 1,
              i + 1,
              i - (y - 1) * y,
              i - y,
              z2,
              z1
            ],
            false
          )

        (rem_iz > y * (y - 1) or rem_iz == 0) and rem_iy == 0 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i - 1,
              i - y + 1,
              i - (y - 1) * y,
              i - y,
              z2,
              z1
            ],
            false
          )

        rem(i, z) <= y and rem(i, y) == 1 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i + y - 1,
              i + 1,
              i + y,
              i + (y - 1) * y,
              z2,
              z1
            ],
            false
          )

        rem(i, z) <= y and rem(i, y) == 0 ->
          set_neighbors_helper(
            list_nodes,
            [
              i,
              i - 1,
              i - y + 1,
              i + y,
              i + (y - 1) * y,
              z2,
              z1
            ],
            false
          )

        rem_iz > y * (y - 1) or rem_iz == 0 ->
          set_neighbors_helper(
            list_nodes,
            [i, i - 1, i + 1, i - (y - 1) * y, i - y, z2, z1],
            false
          )

        rem_iz <= y ->
          set_neighbors_helper(
            list_nodes,
            [i, i - 1, i + 1, i + y, i + (y - 1) * y, z2, z1],
            false
          )

        rem_iy == 1 ->
          set_neighbors_helper(list_nodes, [i, i + y - 1, i + 1, i + y, i - y, z2, z1], false)

        rem_iy == 0 ->
          set_neighbors_helper(list_nodes, [i, i - 1, i - y + 1, i + y, i - y, z2, z1], false)

        true ->
          set_neighbors_helper(list_nodes, [i, i - 1, i + 1, i + y, i - y, z2, z1], false)
      end
    end
  end

  def build_honeycomb_topology(num_nodes, list_nodes, is_random) do
    grid_size = :math.sqrt(num_nodes) |> round()
    numbers = 1..(grid_size * grid_size)
    list = Enum.to_list(numbers)

    for i <- 1..(grid_size * grid_size) do
      remainder = rem(i, grid_size)
      remainder_two = rem(remainder, 4)
      remainder_right = rem(grid_size, 4)

      middle =
        i > grid_size and i < grid_size * grid_size - grid_size + 1 and remainder != 0 and
          remainder != 1

      left_line = remainder == 1
      right_line = remainder == 0
      bottom_line = i <= grid_size
      top_line = i > grid_size * grid_size - grid_size + 1

      corner =
        i == 1 or i == grid_size or i == grid_size * grid_size or
          i == grid_size * grid_size + 1 - grid_size

      top_right = i > grid_size * grid_size - 1
      bottom_right = i == grid_size

      cond do
        right_line == true and remainder_right == 0 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 1 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 2 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1, i - grid_size - 1], is_random)

        right_line == true and remainder_right == 3 and top_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 0 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1, i + grid_size - 1], is_random)

        right_line == true and remainder_right == 1 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 2 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 3 and bottom_right == true ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 0 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1, i - grid_size - 1], is_random)

        right_line == true and remainder_right == 1 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 2 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        right_line == true and remainder_right == 3 and corner == false ->
          set_neighbors_helper(list_nodes, [i, i - 1], is_random)

        remainder_two == 0 and bottom_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i + grid_size - 1], is_random)

        remainder_two == 1 and bottom_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i + grid_size + 1], is_random)

        remainder_two == 2 and bottom_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random)

        remainder_two == 3 and bottom_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random)

        remainder_two == 0 and top_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random)

        remainder_two == 1 and top_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1], is_random)

        remainder_two == 2 and top_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i - grid_size - 1], is_random)

        remainder_two == 3 and top_line == true and corner == false ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i - grid_size + 1], is_random)

        remainder_two == 0 and middle == true ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i + grid_size - 1], is_random)

        remainder_two == 1 and middle == true ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i + grid_size + 1], is_random)

        remainder_two == 2 and middle == true ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i - grid_size - 1], is_random)

        remainder_two == 3 and middle == true ->
          set_neighbors_helper(list_nodes, [i, i + 1, i - 1, i - grid_size + 1], is_random)

        left_line == true and i == grid_size * grid_size + 1 - grid_size ->
          set_neighbors_helper(list_nodes, [i, i + 1], is_random)

        left_line == true and i != grid_size * grid_size + 1 - grid_size ->
          set_neighbors_helper(list_nodes, [i, i + 1, i + grid_size + 1], is_random)

        true ->
          set_neighbors_helper(list_nodes, [i], is_random)
      end
    end
  end

  def build_rand2D_topology(list_nodes) do
    coordinates_map = Enum.reduce(list_nodes, %{}, &random_coordinates_generator/2)

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

  defp random_coordinates_generator(elem, map) do
    Map.put(map, elem, [:rand.uniform(), :rand.uniform()])
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
        i == 0 -> set_neighbors_helper_line(list_nodes, [i, i + 1])
        i == num_nodes - 1 -> set_neighbors_helper_line(list_nodes, [i, i - 1])
        true -> set_neighbors_helper_line(list_nodes, [i, i - 1, i + 1])
      end
    end
  end

  defp set_neighbors_helper_line(list_nodes, neighborhood) do
    [self_index | neighbors_index] = neighborhood

    neighbors =
      for i <- neighbors_index do
        Enum.at(list_nodes, i)
      end

    GenServer.cast(Enum.at(list_nodes, self_index), {:set_neighbors, neighbors})
  end

  defp set_neighbors_helper(list_nodes, neighborhood, is_random) do
    [self_index | neighbors_index] = neighborhood
    # Shifted the nodes' position by one because we designed
    #  torus and honeybcomb with nodes starting at 1 instead of 0
    list_nodes = [nil | list_nodes]

    neighbors =
      for i <- neighbors_index do
        Enum.at(list_nodes, i)
      end

    neighbors = if is_random, do: [neighbors | Enum.random(list_nodes)], else: neighbors
    GenServer.cast(Enum.at(list_nodes, self_index), {:set_neighbors, neighbors})
  end
end
