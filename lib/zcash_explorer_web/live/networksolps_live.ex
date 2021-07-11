defmodule ZcashExplorerWeb.NetworkSolpsLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <p class="text-2xl font-semibold text-gray-900">
    <%= @networksolps %>
    </p>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 30000)

    case Cachex.get(:app_cache, "networksolps") do
      {:ok, info} ->
        {:ok, assign(socket, :networksolps, info)}

      {:error, _reason} ->
        {:ok, assign(socket, :networksolps, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 30000)
    {:ok, info} = Cachex.get(:app_cache, "networksolps")
    {:noreply, assign(socket, :networksolps, info)}
  end
end
