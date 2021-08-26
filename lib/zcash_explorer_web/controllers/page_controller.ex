defmodule ZcashExplorerWeb.PageController do
  use ZcashExplorerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", page_title: "Zcash Explorer - Search the Zcash Blockchain")
  end

  def broadcast(conn, _params) do
    render(conn, "broadcast.html",
      csrf_token: get_csrf_token(),
      page_title: "Broadcast raw Zcash transaction"
    )
  end

  def do_broadcast(conn, params) do
    tx_hex = params["tx-hex"]

    case Zcashex.sendrawtransaction(tx_hex) do
      {:ok, resp} ->
        conn
        |> put_flash(:info, resp)
        |> render("broadcast.html",
          csrf_token: get_csrf_token(),
          page_title: "Broadcast raw Zcash transaction"
        )

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("broadcast.html",
          csrf_token: get_csrf_token(),
          page_title: "Broadcast raw Zcash Transaction"
        )
    end
  end

  def disclosure(conn, _params) do
    render(conn, "disclosure.html",
      csrf_token: get_csrf_token(),
      disclosed_data: nil,
      disclosure_hex: nil,
      page_title: "Zcash Payment Disclosure"
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
          disclosure_hex: disclosure_hex,
          page_title: "Zcash Payment Disclosure"
        )

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> render("disclosure.html",
          csrf_token: get_csrf_token(),
          disclosed_data: nil,
          disclosure_hex: disclosure_hex,
          page_title: "Zcash Payment Disclosure"
        )
    end
  end

  def mempool(conn, _params) do
    render(conn, "mempool.html", page_title: "Zcash Mempool")
  end

  def nodes(conn, _params) do
    render(conn, "nodes.html", page_title: "Zcash Nodes")
  end

  def vk(conn, _params) do
    height =
      case Cachex.get(:app_cache, "metrics") do
        {:ok, info} ->
          info["blocks"] - 10000

        {:error, _reason} ->
          # hardcoded to canopy
          1_046_400
      end

    render(conn, "vk.html",
      csrf_token: get_csrf_token(),
      height: height,
      page_title: "Zcash Viewing Key"
    )
  end

  def do_import_vk(conn, params) do
    height = params["scan-height"]
    vkey = params["vkey"]

    with true <- String.starts_with?(vkey, "zxview"),
         true <- is_integer(String.to_integer(height)),
         true <- String.to_integer(height) >= 0,
         true <- Cachex.get!(:app_cache, "nbjobs") <= 10 do
      cmd =
        MuonTrap.cmd("docker", [
          "create",
          "-t",
          "-i",
          "--rm",
          "--cpus",
          Application.get_env(:zcash_explorer, Zcashex)[:vk_cpus],
          "-m",
          Application.get_env(:zcash_explorer, Zcashex)[:vk_mem],
          Application.get_env(:zcash_explorer, Zcashex)[:vk_runnner_image],
          "zecwallet-cli",
          "import",
          vkey,
          height
        ])

      container_id = elem(cmd, 0) |> String.trim_trailing("\n") |> String.slice(0, 12)
      Task.start(fn -> MuonTrap.cmd("docker", ["start", "-a", "-i", container_id]) end)

      render(conn, "vk_txs.html",
        csrf_token: get_csrf_token(),
        height: height,
        container_id: container_id,
        page_title: "Zcash Viewing Key"
      )
    else
      false ->
        conn
        |> put_flash(:error, "Invalid Input")
        |> render("vk.html",
          csrf_token: get_csrf_token(),
          height: height,
          page_title: "Zcash Viewing Key"
        )
    end
  end

  def vk_from_zecwalletcli(conn, params) do
    container_id = Map.get(params, "hostname")
    chan = "VK:" <> "#{container_id}"
    txs = Map.get(params, "_json")
    Phoenix.PubSub.broadcast(ZcashExplorer.PubSub, chan, {:received_txs, txs})
    json(conn, %{status: "received"})
  end

  def blockchain_info(conn, _params) do
    render(conn, "blockchain_info.html", page_title: "Zcash Blockchain Info")
  end
end
