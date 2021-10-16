defmodule ZcashExplorerWeb.TransactionController do
  use ZcashExplorerWeb, :controller

  def get_transaction(conn, %{"txid" => txid}) do
    {:ok, tx} = Zcashex.getrawtransaction(txid, 1)
    tx_data = Zcashex.Transaction.from_map(tx)
    IO.inspect(tx_data)
    render(conn, "tx.html", tx: tx_data, page_title: "Zcash Transaction #{txid}")
  end
end
