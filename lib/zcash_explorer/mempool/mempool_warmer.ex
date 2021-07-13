defmodule ZcashExplorer.Mempool.MempoolWarmer do
  use Cachex.Warmer

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.seconds(5)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    Zcashex.getrawmempool(true) |> handle_result()
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, _reason}),
    do: :ignore

  defp handle_result({:ok, raw_mempool}) do
    mempool_info = Enum.map(raw_mempool, fn {k, v} -> %{"txid" => k, "info" => v} end)
    {:ok, [{"raw_mempool", mempool_info}]}
  end
end
