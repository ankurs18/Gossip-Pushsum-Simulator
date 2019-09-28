defmodule GPS.NodeWorker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(state) do
    neighbors = []
    count = 0
    {:ok, {neighbors, count}}
  end

  def handle_cast({:set_neighbours, new_neighbors}, {neighbors, count}) do
    {:noreply, {new_neighbors, count}}
  end

  def handle_cast({:add_neighbour, new_neighbor}, {neighbors, count}) do
    {:noreply, {neighbors ++ [new_neighbor], count}}
  end

  def handle_call({:pick_random}, _from, {neighbors, count}) do
    random_pid = Enum.random(neighbors)
    {:reply, random_pid, {neighbors, count}}
  end

  def handle_call({:fetch_neighbors}, _from, {neighbors, count}) do
    {:reply, neighbors, {neighbors, count}}
  end
end
