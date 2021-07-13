defmodule ZcashExplorerWeb.PageController do
  use ZcashExplorerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def broadcast(conn, _params) do
    render(conn, "broadcast.html", csrf_token: get_csrf_token())
  end

  def do_broadcast(conn, params) do
    tx_hex = params["tx-hex"]

    case Zcashex.sendrawtransaction(tx_hex) do
      {:ok, resp} ->
        # IO.inspect(resp)
        conn
        |> put_flash(:info, resp)
        |> render("broadcast.html", csrf_token: get_csrf_token())

      {:error, reason} ->
        # IO.inspect(reason)
        conn
        |> put_flash(:error, reason)
        |> render("broadcast.html", csrf_token: get_csrf_token())
    end
  end

  def disclosure(conn, _params) do
    render(conn, "disclosure.html",
      csrf_token: get_csrf_token(),
      disclosed_data: nil,
      disclosure_hex: nil
    )
  end

  def do_disclosure(conn, params) do
    disclosure_hex = String.trim(params["disclosure-hex"])

    case Zcashex.z_validatepaymentdisclosure(disclosure_hex) do
      {:ok, resp} ->
        conn
        |> put_flash(:info, resp)
        |> render("disclosure.html",
          csrf_token: get_csrf_token(),
          disclosed_data: resp,
          disclosure_hex: disclosure_hex
        )

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("disclosure.html",
          csrf_token: get_csrf_token(),
          disclosed_data: nil,
          disclosure_hex: disclosure_hex
        )
    end
  end

  def mempool(conn, _params) do
    render(conn, "mempool.html")
  end
end
