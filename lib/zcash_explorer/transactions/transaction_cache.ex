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
    low = DateTime.utc_now() |> DateTime.add(-600, :second) |> DateTime.to_unix()
    # get the blocks mined in that duration

    case Zcashex.getblockhashes(high, low, true, false) do
      {:ok, blocks} ->
        # enrich the blocks
        blocks
        |> Enum.map(fn x ->
          {:ok, block} = Zcashex.getblock(x, 1)
          tx = block["tx"]
        end)
        |> List.flatten()
        |> Enum.take(5)
        |> Enum.map(fn y ->
          {:ok, tx} = Zcashex.getrawtransaction(y, 1)
          tx
        end)
        |> Enum.map(fn z ->
          %{
            "txid" => z["txid"],
            "block_height" => z["height"],
            "time" => ZcashExplorerWeb.BlockView.mined_time(z["time"]),
            "tx_out_total" => ZcashExplorerWeb.BlockView.tx_out_total(z),
            "size" => z["size"]
          }
        end)
        |> handle_result

      {:error, reason} ->
        {:error, reason} |> handle_result
    end
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, _reason}) do
    Logger.error("Error while warming the transaction cache.")
    :ignore
  end

  defp handle_result(info) do
    {:ok, [{"transaction_cache", info}]}
  end
end
