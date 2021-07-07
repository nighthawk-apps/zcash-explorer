defmodule ZcashExplorer.Price.PriceService do
  @moduledoc false

  def fetch_current_price() do
    case fetch_price() do
      nil ->
        {:error, "Unable to fetch ZEC price in USD"}

      price ->
        {:ok, String.to_float(price)}
    end
  end

  defp fetch_price() do
    url()
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!()
    |> Map.get("bid")
  end

  defp url() do
    "https://api.gemini.com/v2/ticker/zecusd"
  end
end
