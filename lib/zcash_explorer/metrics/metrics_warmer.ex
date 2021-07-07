defmodule ZcashExplorer.Metrics.MetricsWarmer do
  use Cachex.Warmer

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.seconds(15)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    Zcashex.getblockchaininfo() |> handle_result()
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, _reason}),
    do: :ignore

  defp handle_result({:ok, info}) do
    {:ok, [{"metrics", info}]}
  end
end
