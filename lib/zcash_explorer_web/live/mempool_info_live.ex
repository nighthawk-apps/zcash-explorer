defmodule ZcashExplorerWeb.MempoolInfoLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <p class="text-2xl font-semibold text-gray-900">
    <%= @mempool_info %>
    </p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    case Cachex.get(:app_cache, "mempool_info") do
      {:ok, info} ->
        {:ok, assign(socket, :mempool_info, info["size"])}

      {:error, _reason} ->
        {:ok, assign(socket, :mempool_info, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:ok, info} = Cachex.get(:app_cache, "mempool_info")
    {:noreply, assign(socket, :mempool_info, info["size"])}
  end
end
