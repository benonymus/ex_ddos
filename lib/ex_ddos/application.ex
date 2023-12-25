defmodule ExDdos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # a bit overkill for this
      {Cachex, name: :counts},
      {Registry, [keys: :duplicate, name: BotRegistry, partitions: System.schedulers_online()]},
      {DynamicSupervisor, strategy: :one_for_one, name: ExDdos.BotSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDdos.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
