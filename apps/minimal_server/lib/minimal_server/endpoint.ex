defmodule MinimalServer.Endpoint do
  use Plug.Router

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    IO.puts("listening to port 4000")
    Plug.Adapters.Cowboy.http(__MODULE__, [])
  end

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/api", to: MinimalServer.Router)

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end
end
