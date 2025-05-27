defmodule ZcashExplorer.Blocks.BlockWarmer do
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

    case Zcashex.getblockhashes(high, low, true, false) do
      {:ok, blocks} ->
        # enrich the blocks
        blocks
        |> Enum.map(fn x ->
          {:ok, block} = Zcashex.getblock(x, 2)
          block_struct = Zcashex.Block.from_map(block)

          %{
            "height" => block_struct.height,
            "size" => block_struct.size,
            "hash" => block_struct.hash,
            "time" => ZcashExplorerWeb.BlockView.mined_time(block_struct.time),
            "tx_count" => ZcashExplorerWeb.BlockView.transaction_count(block_struct.tx),
            "output_total" => ZcashExplorerWeb.BlockView.output_total(block_struct.tx)
          }
        end)
        |> Enum.sort(&(&1["height"] >= &2["height"]))
        |> handle_result

      {:error, reason} ->
        {:error, reason} |> handle_result
    end
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, reason}) do
    Logger.error("Error while warming the block cache.#{inspect(reason)}")
    :ignore
  end

  defp handle_result(info) do
    {:ok, [{"block_cache", info}]}
  end
end
