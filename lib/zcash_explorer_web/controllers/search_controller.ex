defmodule ZcashExplorerWeb.SearchController do
  use ZcashExplorerWeb, :controller

  def search(conn, %{"qs" => qs}) do
    tasks = [
      block_resp = Task.async(fn -> Zcashex.getblock(qs, 0) end),
      tx_resp = Task.async(fn -> Zcashex.getrawtransaction(qs, 0) end),
      tadd_resp = Task.async(fn -> Zcashex.validateaddress(qs) end),
      zadd_resp = Task.async(fn -> Zcashex.z_validateaddress(qs) end)
    ]

    run = Task.yield_many(tasks, 5000)

    results =
      Enum.map(run, fn {task, res} ->
        # Shut down the tasks that did not reply nor exit
        res || Task.shutdown(task, :brutal_kill)
      end)

    {:ok, block_resp} = Enum.at(results, 0)
    {:ok, tx_resp} = Enum.at(results, 1)
    {:ok, tadd_resp} = Enum.at(results, 2)
    {:ok, zadd_resp} = Enum.at(results, 3)

    cond do
      is_valid_block?(block_resp) ->
        redirect(conn, to: "/blocks/#{qs}")

      is_valid_tx?(tx_resp) ->
        redirect(conn, to: "/transactions/#{qs}")

      is_valid_taddr?(tadd_resp) ->
        redirect(conn, to: "/address/#{qs}")

      is_valid_zaddr?(zadd_resp) ->
        redirect(conn, to: "/address/#{qs}")

      true ->
        conn
        |> put_status(:not_found)
        |> put_view(ZcashExplorerWeb.ErrorView)
        |> render(:invalid_input)
    end
  end

  def is_valid_block?({:ok, hex}) do
    true
  end

  def is_valid_block?({:error, reason}) do
    false
  end

  def is_valid_block?({:ok, {:error, "Block not found"}}) do
    false
  end

  def is_valid_tx?({:ok, hex}) do
    true
  end

  def is_valid_tx?({:error, reason}) do
    false
  end

  def is_valid_taddr?({:ok, %{"isvalid" => true}}) do
    true
  end

  def is_valid_taddr?({:ok, %{"isvalid" => false}}) do
    false
  end

  def is_valid_zaddr?({:ok, %{"isvalid" => true}}) do
    true
  end

  def is_valid_zaddr?({:ok, %{"isvalid" => false}}) do
    false
  end
end
