defmodule ExDdos.BotSupervisor do
  use DynamicSupervisor

  def start_link(init_arg),
    do: DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)

  def start_child(args), do: DynamicSupervisor.start_child(__MODULE__, {ExDdos.Bot, args})

  @impl true
  def init(_init_arg), do: DynamicSupervisor.init(strategy: :one_for_one)
end
