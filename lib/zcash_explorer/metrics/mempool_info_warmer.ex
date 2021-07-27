defmodule ZcashExplorer.Metrics.MempoolInfoWarmer do
  alias ZcashExplorer.Metrics.MetricsService
  use Cachex.Warmer

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.seconds(3)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    Zcashex.getmempoolinfo() |> handle_result()
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, _reason}),
    do: :ignore

  defp handle_result({:ok, mempool_info}) do
    {:ok, [{"mempool_info", mempool_info}]}
  end
end
