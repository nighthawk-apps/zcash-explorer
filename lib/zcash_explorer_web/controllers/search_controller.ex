defmodule ZcashExplorerWeb.SearchController do
  use ZcashExplorerWeb, :controller

  def search(conn, %{"qs" => qs}) do
    qs = String.trim(qs)
    # query zcashd to find out if the user has entered a valid resource
    # Valid resources:
    #  Block - height, hash
    #  Transaction - hash 
    #  Address - Transparent , Shielded
    # If zcashd responds that a resource is valid, we redirect the user 
    # to the appropriate resource view or redirect them to an error view.
    tasks = [
      Task.async(fn -> Zcashex.getblock(qs, 0) end),
      Task.async(fn -> Zcashex.getrawtransaction(qs, 0) end),
      Task.async(fn -> Zcashex.validateaddress(qs) end),
      Task.async(fn -> Zcashex.z_validateaddress(qs) end)
    ]

    run = Task.yield_many(tasks, 5000)

    results =
      Enum.map(run, fn {task, res} ->
        # Shut down the tasks that did not reply nor exit
        res || Task.shutdown(task, :brutal_kill)
      end)

    # order in which the tasks are above defined matters
    {:ok, block_resp} = Enum.at(results, 0)
    {:ok, tx_resp} = Enum.at(results, 1)
    {:ok, tadd_resp} = Enum.at(results, 2)
    {:ok, zadd_resp} = Enum.at(results, 3)

    IO.inspect(block_resp)
    IO.inspect(tx_resp)
    IO.inspect(tadd_resp)
    IO.inspect(zadd_resp)

    cond do
      is_valid_block?(block_resp) ->
        redirect(conn, to: "/blocks/#{qs}")

      is_valid_tx?(tx_resp) ->
        redirect(conn, to: "/transactions/#{qs}")

      is_valid_taddr?(tadd_resp) ->
        redirect(conn, to: "/address/#{qs}")

      is_valid_zaddr?(zadd_resp) ->
        redirect(conn, to: "/address/#{qs}")

      is_valid_unified_address?(zadd_resp) ->
        redirect(conn, to: "/ua/#{qs}")

      true ->
        conn
        |> put_status(:not_found)
        |> put_view(ZcashExplorerWeb.ErrorView)
        |> render(:invalid_input)
    end
  end

  def is_valid_block?({:ok, {:error, "Block not found"}}) do
    false
  end

  def is_valid_block?({:ok, _hex}) do
    true
  end

  def is_valid_block?({:error, _reason}) do
    false
  end

  def is_valid_tx?({:ok, _hex}) do
    true
  end

  def is_valid_tx?({:error, _reason}) do
    false
  end

  def is_valid_taddr?({:ok, %{"isvalid" => true}}) do
    true
  end

  def is_valid_taddr?({:ok, %{"isvalid" => false}}) do
    false
  end

  def is_valid_zaddr?({:ok, %{"isvalid" => true, "type" => "sprout"}}) do
    true
  end

  def is_valid_zaddr?({:ok, %{"isvalid" => true, "type" => "sapling"}}) do
    true
  end

  def is_valid_zaddr?({:ok, %{"isvalid" => true, "type" => "unified"}}) do
    false
  end

  def is_valid_zaddr?({:ok, %{"isvalid" => false}}) do
    false
  end

  def is_valid_unified_address?({:ok, %{"isvalid" => true, "type" => "unified"}}) do
    true
  end

  def is_valid_unified_address?(resp) do
    false
  end
end
