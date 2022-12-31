defmodule ZcashExplorerWeb.DifficultyLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <p class="text-2xl font-semibold text-gray-900 dark:dark:bg-slate-800 dark:text-slate-100">
    <%= Float.ceil(@difficulty,6) %>
    </p>
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

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:noreply, assign(socket, :difficulty, info["difficulty"])}
  end
end
