defmodule ZcashExplorerWeb.BlockChainSizeLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= Sizeable.filesize(@blockchain_size) %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 15000)

    case Cachex.get(:app_cache, "metrics") do
      {:ok, info} ->
        {:ok, assign(socket, :blockchain_size, info["size_on_disk"])}

      {:error, _reason} ->
        {:ok, assign(socket, :blockchain_size, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 15000)
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:noreply, assign(socket, :blockchain_size, info["size_on_disk"])}
  end
end
