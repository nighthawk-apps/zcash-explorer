defmodule ZcashExplorer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Cachex.Spec

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # ZcashExplorer.Repo,
      # Start the Telemetry supervisor
      ZcashExplorerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ZcashExplorer.PubSub},
      # Start the Endpoint (http/https)
      ZcashExplorerWeb.Endpoint,
      # Start a worker by calling: ZcashExplorer.Worker.start_link(arg)
      %{
        id: Zcashex,
        start:
          {Zcashex, :start_link,
           [
             Application.get_env(:zcash_explorer, Zcashex)[:zcashd_hostname],
             String.to_integer(Application.get_env(:zcash_explorer, Zcashex)[:zcashd_port]),
             Application.get_env(:zcash_explorer, Zcashex)[:zcashd_username],
             Application.get_env(:zcash_explorer, Zcashex)[:zcashd_password]
           ]}
      },
      {Cachex,
       name: :app_cache,
       warmers: [
         warmer(module: ZcashExplorer.Metrics.MetricsWarmer, state: {}),
         warmer(module: ZcashExplorer.Metrics.MempoolInfoWarmer, state: {}),
         warmer(module: ZcashExplorer.Metrics.NetworkSolpsWarmer, state: {}),
         warmer(module: ZcashExplorer.Blocks.BlockWarmer, state: {}),
         warmer(module: ZcashExplorer.Transactions.TransactionWarmer, state: {}),
         warmer(module: ZcashExplorer.Mempool.MempoolWarmer, state: {}),
         warmer(module: ZcashExplorer.Nodes.NodeWarmer, state: {}),
         warmer(module: ZcashExplorer.Metrics.InfoWarmer, state: {})
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ZcashExplorer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ZcashExplorerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
