defmodule ZcashExplorerWeb.BlockCountLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= @block_count %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 15000)

    case Cachex.get(:app_cache, "metrics") do
      {:ok, info} ->
        {:ok, assign(socket, :block_count, info["blocks"])}

      {:error, _reason} ->
        {:ok, assign(socket, :block_count, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 15000)
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:noreply, assign(socket, :block_count, info["blocks"])}
  end
end
