defmodule GPS.Gossip.Driver do
  use GenServer

  def begin(pid) do
    GenServer.cast(pid, {:begin})
  end

  def start_link(time, nodes_list) do
    GenServer.start_link(__MODULE__, {time, nodes_list})
  end

  def check_convergence(nodes_list, start_time) do
    nodes_list = Enum.filter(nodes_list, fn pid -> Process.alive?(pid) end)
    len = length(nodes_list)
    IO.puts("nodes remaining=  #{len}")

    if(len <= 1) do
      IO.puts("nodes remaining=  #{len}")
      # IO.puts("convergence no=  #{convergance_num}")

      end_time = System.monotonic_time(:millisecond)
      time_taken = end_time - start_time
      IO.puts("Time taken: #{time_taken}")
      System.halt(0)
    else
      check_convergence(nodes_list, start_time)
    end
  end

  def init({time, nodes_list}) do
    {:ok, {time, nodes_list}}
  end

  def handle_cast({:begin}, {time, nodes_list}) do
    GPS.Gossip.Node.send_message(Enum.random(nodes_list), :rumor)
    check_convergence(nodes_list, time)
    {:noreply, {time, nodes_list}}
  end
end
