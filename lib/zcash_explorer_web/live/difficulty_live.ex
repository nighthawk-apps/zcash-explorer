defmodule ZcashExplorerWeb.DifficultyLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= @difficulty %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 5000)

    case Cachex.get(:app_cache, "metrics") do
      {:ok, info} ->
        {:ok, assign(socket, :difficulty, info["difficulty"])}

      {:error, _reason} ->
        {:ok, assign(socket, :difficulty, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:noreply, assign(socket, :difficulty, info["difficulty"])}
  end
end
