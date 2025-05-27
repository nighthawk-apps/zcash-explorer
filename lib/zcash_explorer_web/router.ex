defmodule ZcashExplorerWeb.Router do
  use ZcashExplorerWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {ZcashExplorerWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZcashExplorerWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/blocks/:hash", BlockController, :get_block
    get "/transactions/:txid", TransactionController, :get_transaction
    live "/price", PriceLive
    live "/metrics/difficulty", DifficultyLive
    live "/metrics/block_count", BlockCountLive
    live "/metrics/blockchain_size", BlockChainSizeLive
    live "/metrics/mempool_info", MempoolInfoLive
    live "/metrics/networksolps", NetworkSolpsLive
    live "/index/recent_blocks", RecentBlocksLive
    live "/index/recent_transactions", RecentTransactionsLive
    live "/live/raw_mempool", RawMempoolLive
    live "/live/orchard_pool", OrchardPoolLive
    live "/live/nodes", NodesLive
    live "/vkdetails", VkLive
    live "/blockchain-info-live", BlockChainInfoLive
    get "/broadcast", PageController, :broadcast
    post "/broadcast", PageController, :do_broadcast
    get "/payment-disclosure", PageController, :disclosure
    post "/payment-disclosure", PageController, :do_disclosure
    get "/address/:address", AddressController, :get_address
    get "/search", SearchController, :search
    get "/blocks", BlockController, :index
    get "/mempool", PageController, :mempool
    get "/nodes", PageController, :nodes
    get "/vk", PageController, :vk
    post "/vk", PageController, :do_import_vk
    get "/blockchain-info", PageController, :blockchain_info
    get "/ua/:address", AddressController, :get_ua
  end

  scope "/", ZcashExplorerWeb do
    pipe_through :api
    get "/api/v1/blockchain-info", PageController, :blockchain_info_api
    get "/api/v1/supply", PageController, :supply
    post "/api/vk/:hostname", PageController, :vk_from_zecwalletcli
    get "/transactions/:txid/raw", TransactionController, :get_raw_transaction
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZcashExplorerWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: ZcashExplorerWeb.Telemetry,
        ecto_repos: [ZcashExplorer.Repo]
    end
  end
end
