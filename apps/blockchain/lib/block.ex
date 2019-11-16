defmodule Block do
  defstruct hash: "some random hash",
            data: "{ \"hello\": \"world\" }",
            next: "some random hash",
            timestamp: NaiveDateTime.utc_now()

  use GenServer

  @spec init(Block) :: {:ok, Block}
  def init(block) do
    {:ok, block}
  end

  def valid?(%Block{} = block) do
    Crypto.hash(block) == block.hash
  end

  def valid?(%Block{} = block, %Block{} = next_block) do
    block.next == next_block.hash && valid?(block)
  end

  def info(process) do
    GenServer.call(process, {:info})
  end

  def handle_call({:info}, _from, state) do
    {:reply, state, state}
  end
end
