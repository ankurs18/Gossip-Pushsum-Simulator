defmodule GPS.Gossip.Node do
  use GenServer

  ####################### API ##############################
  def send_message(pid, message) do
    GenServer.cast(pid, {:send_next, message})
  end

  

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end
  ####################### SERVER ##############################
  def init(_args) do
    neighbors = []
    count = 0
    is_active = true
    {:ok, {neighbors, count, is_active}}
  end


  def handle_cast({:set_neighbors, new_neighbors}, {_neighbors, count, is_active}) do
    {:noreply, {new_neighbors, count, is_active}}
  end

  

  def handle_cast({:send_next, message}, {neighbors, count, is_active}) do
    new_count = count + 1

    if new_count == 1 do
      Task.start_link(__MODULE__, :propogate_gossip, [neighbors])
    end

    if new_count == 10 do
      exit(:normal)
    end

    {:noreply, {neighbors, new_count, is_active}}
  end

  def propogate_gossip(neighbors) do
    if length(neighbors) > 0 do
      active_neighbors = Enum.filter(neighbors, fn pid -> Process.alive?(pid) end)

      if length(active_neighbors) > 0 do
        curr_neighbor = Enum.random(active_neighbors)
        send_message(curr_neighbor, :rumor)
        # IO.inspect(%{"self" => self(), "to" => curr_neighbor})
        :timer.sleep(100)
        propogate_gossip(active_neighbors)
      end
    end
  end

  def handle_cast({:add_neighbor, new_neighbor}, {neighbors, count, is_active}) do
    {:noreply, {neighbors ++ [new_neighbor], count, is_active}}
  end

  def resend_gossip(pid) do
    Process.send_after(pid, {:gossip_resend}, 500)
  end
  
  def handle_info({:gossip_resend}, state) do
    send_message(self(), :periodic_message)
    {:noreply, state}
  end
  
    # def handle_cast({:send_next_old, message}, {neighbors, count, is_active}) do
  #   active_neighbors = Enum.filter(neighbors, fn pid -> GPS.Gossip.Node.check_active(pid) end)

  #   if count <= 10 and length(active_neighbors) > 0 do
  #     IO.puts("len: #{length(active_neighbors)}")
  #     curr_neighbor = Enum.random(active_neighbors)

  #     IO.inspect(curr_neighbor)
  #     send_message(curr_neighbor, :rumor)
  #   end

  #   is_active = if count == 10, do: false, else: is_active

  #   IO.inspect(%{"pid" => self(), "count" => count})

  #   # count = if message == :rumor, do: count + 1, else: count
  #   resend_gossip(self())
  #   {:noreply, {neighbors, count + 1, is_active}}
  # end

  # def handle_call({:isactive}, _from, {neighbors, count, is_active}) do
  #   {:reply, is_active, {neighbors, count, is_active}}
  # end

  # def handle_call({:fetch_count}, _from, {neighbors, count, is_active}) do
  #   {:reply, count, {neighbors, count, is_active}}
  # end

  # def handle_call({:pick_random}, _from, {neighbors, count, is_active}) do
  #   random_pid = Enum.random(neighbors)
  #   {:reply, random_pid, {neighbors, count, is_active}}
  # end
end
