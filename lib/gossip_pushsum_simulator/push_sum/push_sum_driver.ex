defmodule GPS.PushSum.Driver do
  use GenServer

  def begin(pid) do
    # IO.puts("begin")
    GenServer.cast(pid, {:begin})
  end

  def start_link(time, nodes_list) do
    GenServer.start_link(__MODULE__, {time, nodes_list})
  end

  def init({time, nodes_list}) do
    {:ok, {time, nodes_list}}
  end

  def handle_cast({:begin}, {time, nodes_list}) do
    GPS.PushSum.Node.send_message(Enum.random(nodes_list), 0, 0)
    {:noreply, {time, nodes_list}}
  end
end
