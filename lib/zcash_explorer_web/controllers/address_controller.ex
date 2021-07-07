defmodule ZcashExplorerWeb.AddressController do
  use ZcashExplorerWeb, :controller

  def get_address(conn, %{"address" => address, "s" => s, "e" => e}) do
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    blocks = info["blocks"]

    e = String.to_integer(e)
    s = String.to_integer(s)

    # if requesting for a block that's not yet mined, cap the request to the latest block
    capped_e = if e > blocks, do: blocks, else: e

    {:ok, balance} = Zcashex.getaddressbalance(address)
    {:ok, deltas} = Zcashex.getaddressdeltas(address, s, capped_e, true)
    txs = Map.get(deltas, "deltas") |> Enum.reverse()

    qr =
      address
      |> EQRCode.encode()
      |> EQRCode.png(width: 150, color: <<0, 0, 0>>, background_color: :transparent)
      |> Base.encode64()

    render(conn, "address.html",
      address: address,
      balance: balance,
      txs: txs,
      qr: qr,
      end_block: e,
      start_block: s,
      latest_block: blocks,
      capped_e: capped_e
    )
  end

  def get_address(conn, %{"address" => address}) do
    c = 128
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    latest_block = info["blocks"]
    e = latest_block
    s = ((c - 1) * (e / c)) |> floor()
    s = if s <= 0, do: 1, else: s
    {:ok, balance} = Zcashex.getaddressbalance(address)
    {:ok, deltas} = Zcashex.getaddressdeltas(address, s, e, true)
    txs = Map.get(deltas, "deltas") |> Enum.reverse()

    qr =
      address
      |> EQRCode.encode()
      |> EQRCode.png(width: 150, color: <<0, 0, 0>>, background_color: :transparent)
      |> Base.encode64()

    render(conn, "address.html",
      address: address,
      balance: balance,
      txs: txs,
      qr: qr,
      end_block: e,
      start_block: s,
      latest_block: latest_block,
      capped_e: nil
    )
  end
end
