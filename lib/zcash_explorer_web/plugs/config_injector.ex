defmodule ZcashExplorerWeb.Plugs.ConfigInjector do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    zcash_network = Application.get_env(:zcash_explorer, Zcashex)[:zcash_network]
    assign(conn, :zcash_network, zcash_network)
  end
end
