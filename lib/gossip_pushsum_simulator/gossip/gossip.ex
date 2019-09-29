defmodule GPS.GossipDriver do
  use GenServer

  def begin(pid) do
    # IO.puts("begin")
    GenServer.cast(pid, {:start})
  end

  def start_link(time, nodes_list) do
    GenServer.start_link(__MODULE__, {time, nodes_list})
  end

  def init({time, nodes_list}) do
    {:ok, {time, nodes_list}}
  end

  def handle_cast({:start}, {time, nodes_list}) do
    GPS.NodeWorker.send_message(Enum.random(nodes_list))
    # check_convergence(nodes_list, time)
    {:noreply, {time, nodes_list}}
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
end
