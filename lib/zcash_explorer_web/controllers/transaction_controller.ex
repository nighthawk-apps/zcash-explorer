defmodule ZcashExplorerWeb.TransactionController do
  use ZcashExplorerWeb, :controller

  def get_transaction(conn, %{"txid" => txid}) do
    {:ok, tx} = Zcashex.getrawtransaction(txid, 1)
    tx_data = Zcashex.Transaction.from_map(tx)
    render(conn, "tx.html", tx: tx_data)
  end
end
