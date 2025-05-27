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
    cur_jobs = Cachex.get!(:app_cache, "nbjobs") || 1

    with true <- String.starts_with?(vkey, "zxview"),
         true <- is_integer(String.to_integer(height)),
         true <- String.to_integer(height) >= 0,
         true <- cur_jobs <= 10 do
      cmd =
        MuonTrap.cmd("docker", [
          "create",
          "-t",
          "-i",
          "--rm",
          "--ulimit",
          "nofile=90000:90000",
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

  def blockchain_info_api(conn, _params) do
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:ok, %{"build" => build}} = Cachex.get(:app_cache, "info")
    info = Map.put(info, "build", build)
    json(conn, info)
  end

  @doc """
  GET /api/supply

  - If no query params: returns valuePools array as JSON.
  - If `q=totalSupply`: returns the total chain supply as plain text.
  - If `q=circulatingSupply`: returns circulating supply (total minus lockbox) as plain text.
  - If invalid query, returns 404.

  ### Example Usage

  - `/api/supply` → `[ %{...}, ... ]`
  - `/api/supply?q=totalSupply` → `"123456.78"`
  - `/api/supply?q=circulatingSupply` → `"654321.09"`
  """
  def supply(conn, params) do
    if params == %{} do 
      {:ok, info} = Cachex.get(:app_cache, "metrics")
      {:ok, %{"build" => build}} = Cachex.get(:app_cache, "info")
      info = Map.put(info, "build", build)
      # Extract the chainValue from the chainSupply map
      value_pools = info["valuePools"]
      json(conn, value_pools)
    else 
      case params["q"] do
        "totalSupply" -> 
          {:ok, info} = Cachex.get(:app_cache, "metrics")
          {:ok, %{"build" => build}} = Cachex.get(:app_cache, "info")
          info = Map.put(info, "build", build)
          # get total supply (chain value)
          total_supply =  get_in(info, ["chainSupply", "chainValue"])
          send_resp(conn, 200, to_string(total_supply))

        "circulatingSupply" -> 
          {:ok, info} = Cachex.get(:app_cache, "metrics")
          {:ok, %{"build" => build}} = Cachex.get(:app_cache, "info")
          info = Map.put(info, "build", build)
          total_supply =  get_in(info, ["chainSupply", "chainValue"])

          value_pools = info["valuePools"] 
          # Find the map where id == "lockbox"
          lockbox = Enum.find(value_pools, fn pool -> pool["id"] == "lockbox" end)
          
          lockbox_supply = lockbox["chainValue"]
          circulating_supply = total_supply - lockbox_supply
          send_resp(conn, 200, to_string(circulating_supply))
        _ -> 
          send_resp(conn, 404, "valid query keys are 'totalSupply' and 'circulatingSupply'")
      end
    end
  end

end
