defmodule ZcashExplorer.Nodes.NodeWarmer do
  use Cachex.Warmer

  @doc """
  Returns the interval for this warmer.
  """
  def interval,
    do: :timer.seconds(60)

  @doc """
  Executes this cache warmer.
  """
  def execute(_state) do
    Zcashex.getpeerinfo() |> handle_result()
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, _reason}),
    do: :ignore

  defp handle_result({:ok, nodes}) do
    {:ok, [{"zcash_nodes", nodes}]}
  end
end
