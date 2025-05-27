defmodule ZcashExplorer.Transactions.TransactionWarmer do
  use Cachex.Warmer
  require Logger

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.seconds(15)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    high = DateTime.utc_now() |> DateTime.to_unix()
    low = DateTime.utc_now() |> DateTime.add(-900, :second) |> DateTime.to_unix()
    # get the blocks mined in that duration

    case Zcashex.getblockhashes(high, low, true, true) do
      {:ok, blocks} ->
        blocks
        |> Enum.sort(&(&1["logicalts"] >= &2["logicalts"]))
        |> Enum.map(fn x ->
          {:ok, block} = Zcashex.getblock(Map.get(x, "blockhash"), 1)
          tx = block["tx"]
        end)
        |> List.flatten()
        |> Enum.take(10)
        |> Enum.map(fn y ->
          {:ok, tx} = Zcashex.getrawtransaction(y, 1)
          tx_data = Zcashex.Transaction.from_map(tx)
          tx_data
        end)
        |> Enum.map(fn z ->
          %{
            "txid" => Map.get(z, :txid),
            "block_height" => Map.get(z, :height),
            "time" => ZcashExplorerWeb.BlockView.mined_time(Map.get(z, :time)),
            "tx_out_total" => ZcashExplorerWeb.BlockView.tx_out_total(z),
            "size" => Map.get(z, :size),
            "type" => ZcashExplorerWeb.BlockView.tx_type(z)
          }
        end)
        |> handle_result

      {:error, reason} ->
        {:error, reason} |> handle_result
    end
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, reason}) do
    Logger.error("Error while warming the transaction cache. #{inspect(reason)}")
    :ignore
  end

  defp handle_result(info) do
    {:ok, [{"transaction_cache", info}]}
  end
end
