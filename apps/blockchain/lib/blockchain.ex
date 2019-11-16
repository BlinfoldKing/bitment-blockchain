defmodule Blockchain do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(any) :: {:ok, [PID]}
  def init(_) do
    {:ok, []}
  end

  def insert(process, data) do
    GenServer.cast(process, {:insert, data})
  end

  def handle_cast({:insert, data}, state) do
    [first | _] = state
    next_block = GenServer.call(first, {:info})

    block =
      %Block{
        data: data,
        next: next_block.hash
      }
      |> Crypto.put_hash()

    {:ok, pid} = GenServer.start(Block, block)
    {:noreply, [pid | state]}
  end

  def get_by_hash(process, hash) do
    GenServer.call(process, {:get, hash})
  end

  def handle_call({:get, hash}, state) do
    result =
      state
      |> Enum.map(fn pid -> GenServer.call(pid, {:info}) end)
      |> Enum.find(fn block -> block.hash == hash end)

    {:reply, result, state}
  end
end
