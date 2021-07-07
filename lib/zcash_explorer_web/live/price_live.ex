defmodule ZcashExplorerWeb.PriceLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    $<%= @price %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 3000)

    case Cachex.get(:app_cache, "price") do
      {:ok, price} ->
        {:ok, assign(socket, :price, price)}

      {:error, _reason} ->
        {:ok, assign(socket, :price, "updating...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 3000)
    {:ok, price} = Cachex.get(:app_cache, "price")
    {:noreply, assign(socket, :price, price)}
  end
end
