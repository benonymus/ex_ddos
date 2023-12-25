defmodule ExDdos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ok = :hackney_pool.start_pool(:big_pool, timeout: 15000, max_connections: 100)

    children = [
      # a bit overkill for this
      Supervisor.child_spec({Cachex, name: :config_store}, id: :cachex_1),
      Supervisor.child_spec({Cachex, name: :counts}, id: :cachex_2),
      {DynamicSupervisor, strategy: :one_for_one, name: ExDdos.BotSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExDdos.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
