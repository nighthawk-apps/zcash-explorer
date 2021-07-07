defmodule ZcashExplorerWeb.PageView do
  use ZcashExplorerWeb, :view

  def price() do
  {:ok, price } = Cachex.get(:price_cache, "price")
  price
  end
end
