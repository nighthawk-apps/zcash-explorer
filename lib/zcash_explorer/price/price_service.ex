defmodule ZcashExplorer.Price.PriceService do
  @moduledoc false

  def fetch_current_price() do
    case fetch_price() do
      nil ->
        {:error, "Unable to fetch ZEC price in USD"}

      price ->
        {:ok, price}
    end
  end

  defp fetch_price() do
    url()
    |> HTTPoison.get!()
    |> Map.get(:body)
    |> Poison.decode!()
  end

  defp url() do
    "https://api.coingecko.com/api/v3/simple/price?ids=zcash&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&include_last_updated_at=true"
  end
end
