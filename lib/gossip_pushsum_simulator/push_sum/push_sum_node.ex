defmodule GPS.PushSum.Node do
  use GenServer

  ####################### API ##############################
  def send_message(pid, s, w) do
    GenServer.cast(pid, {:send_next, s, w})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  ####################### SERVER ##############################
  
  def init([actor_number, start_time]) do
    # IO.puts("init: #{actor_number}")
    {:ok, {[], actor_number, 1, actor_number / 1, 0, start_time}}
  end

  def handle_cast(
        {:send_next, received_s, received_w},
        {neighbors, s, w, sum_estimate, no_change_count, start_time}
      ) do
    s = s + received_s
    w = w + received_w
    change = abs(s / w - sum_estimate)
    # IO.puts(change)

    no_change_count =
      if change <= :math.pow(10, -10) do
        no_change_count + 1
      else
        0
      end

    active_neighbors = Enum.filter(neighbors, fn pid -> Process.alive?(pid) end)

    if length(active_neighbors) > 0 do
      curr_neighbor = Enum.random(active_neighbors)

      # IO.inspect(%{"pid" => self(), "count" => s / w})
      send_message(curr_neighbor, s / 2, w / 2)
    else
      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken inside: #{time_taken}")
      System.halt(0)
    end

    if no_change_count >= 3,
      do: exit(:normal),
      else: {:noreply, {neighbors, s / 2, w / 2, s / w, no_change_count, start_time}}
  end

  # def handle_cast(
  #       {:send_next_new, received_s, received_w},
  #       {neighbors, s, w, sum_estimate, no_change_count, start_time}
  #     ) do
  #   s = s + received_s
  #   w = w + received_w
  #   change = abs(s / w - sum_estimate)
  #   IO.puts(change)

  #   no_change_count =
  #     if change <= :math.pow(10, -10) do
  #       # IO.puts("no change")

  #       IO.puts("no change: #{no_change_count + 1}")
  #       no_change_count + 1
  #     else
  #       0
  #     end

  #   active_neighbors = Enum.filter(neighbors, fn pid -> Process.alive?(pid) end)

  #   if length(active_neighbors) > 0 do
  #     curr_neighbor = Enum.random(active_neighbors)

  #     IO.inspect(%{"pid" => self(), "count" => s / w})
  #     send_message(curr_neighbor, s / 2, w / 2)
  #   else
  #     exit(:normal)
  #   end

  #   if no_change_count >= 3 do
  #     # Process.exit(self(), :normal)
  #     exit(:normal)
  #   else
  #     # IO.puts("nono")
  #   end

  #   {:noreply, {neighbors, s / 2, w / 2, s / w, no_change_count, start_time}}
  # end

  # def handle_cast(
  #       {:send_next_old, received_s, received_w},
  #       {neighbors, s, w, sum_estimate, no_change_count, start_time}
  #     ) do
  #   s = (s + received_s) / 2
  #   w = (w + received_w) / 2
  #   change = abs(s / w - sum_estimate)

  #   # and  do
  #   no_change_count = if change <= :math.pow(10, -10), do: no_change_count + 1, else: 0
  #   # IO.puts("len: #{length(active_neighbors)}")

  #   is_active = if no_change_count >= 3, do: false, else: is_active
  #   active_neighbors = Enum.filter(neighbors, fn pid -> GPS.Gossip.Node.check_active(pid) end)

  #   if is_active and length(active_neighbors) > 0 do
  #     curr_neighbor = Enum.random(active_neighbors)

  #     IO.inspect(%{"pid" => self(), "count" => s / w})
  #     send_message(curr_neighbor, s / 2, w / 2)
  #   end

  #   {:noreply, {neighbors, s, w, s / w, no_change_count, is_active}}
  # end

  def handle_cast(
        {:add_neighbor, new_neighbor},
        {neighbors, s, w, sum_estimate, no_change_count, start_time}
      ) do
    {:noreply, {neighbors ++ [new_neighbor], s, w, sum_estimate, no_change_count, start_time}}
  end

  def handle_cast(
        {:set_neighbors, new_neighbors},
        {_neighbors, s, w, sum_estimate, no_change_count, start_time}
      ) do
    {:noreply, {new_neighbors, s, w, sum_estimate, no_change_count, start_time}}
  end
end
