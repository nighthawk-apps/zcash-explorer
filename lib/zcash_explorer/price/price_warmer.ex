defmodule ZcashExplorer.Price.PriceWarmer do
  @moduledoc """
  Price warmer which caches Zec prices every 30s.
  """
  alias ZcashExplorer.Price.PriceService
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
    PriceService.fetch_current_price() |> handle_result
  end

  # ignores the warmer result in case of error
  defp handle_result({:error, _reason}),
    do: :ignore

  defp handle_result({:ok, price}) do
    {:ok, [{"price", price}]}
  end
end
