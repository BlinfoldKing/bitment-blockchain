defmodule MinimalServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def get_blockchain_pid do
    [blockchain | _] = Supervisor.which_children(MinimalServer.Supervisor)
    {_, child, _, _} = blockchain
    child
  end

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  post "/insert" do
    IO.inspect(conn.body_params)
    data = Poison.encode!(conn.body_params)

    send_resp(
      conn,
      200,
      GenServer.call(get_blockchain_pid(), {:insert, data})
    )
  end

  get "/block/:hash" do
    send_resp(
      conn,
      200,
      Poison.encode!(GenServer.call(get_blockchain_pid(), {:get, conn.params["hash"]}))
    )
  end

  defp message do
    %{
      hello: "world"
    }
  end
end
