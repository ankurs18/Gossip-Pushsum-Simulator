defmodule GPS.NodeWorker do
  use GenServer

  # API
  def send_message(pid) do
    GenServer.cast(pid, {:send_next})
  end

  def check_active(pid) do
    GenServer.call(pid, {:isactive})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(state) do
    neighbors = []
    count = 0
    is_active = true
    {:ok, {neighbors, count, is_active}}
  end

  # Server
  def handle_cast({:set_neighbors, new_neighbors}, {_neighbors, count, is_active}) do
    {:noreply, {new_neighbors, count, is_active}}
  end

  def handle_cast({:send_next}, {neighbors, count, is_active}) do
    active_neighbors = Enum.filter(neighbors, fn pid -> GPS.NodeWorker.check_active(pid) end)

    if count <= 10 and length(active_neighbors) > 0 do
      IO.puts("len: #{length(active_neighbors)}")
      curr_neighbor = Enum.random(active_neighbors)

      IO.inspect(curr_neighbor)
      send_message(curr_neighbor)
    end

    is_active = if count == 10, do: false, else: is_active

    IO.inspect(%{"pid" => self(), "count" => count})
    # IO.puts("count: #{count} neighbors: ")
    {:noreply, {neighbors, count + 1, is_active}}
  end

  def handle_cast({:add_neighbor, new_neighbor}, {neighbors, count, is_active}) do
    {:noreply, {neighbors ++ [new_neighbor], count, is_active}}
  end

  def handle_call({:pick_random}, _from, {neighbors, count, is_active}) do
    random_pid = Enum.random(neighbors)
    {:reply, random_pid, {neighbors, count, is_active}}
  end

  def handle_call({:fetch_neighbors}, _from, {neighbors, count, is_active}) do
    {:reply, neighbors, {neighbors, count, is_active}}
  end

  def handle_call({:fetch_count}, _from, {neighbors, count, is_active}) do
    {:reply, count, {neighbors, count, is_active}}
  end

  def handle_call({:isactive}, _from, {neighbors, count, is_active}) do
    {:reply, is_active, {neighbors, count, is_active}}
  end
end
