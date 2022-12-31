defmodule ZcashExplorerWeb.RecentBlocksLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <div class="shadow overflow-hidden border-gray-200 rounded-lg overflow-x-auto">
        <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
            <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
            <tr>
                <th scope="col" class="px-6 py-3">Height</th>
                <th scope="col" class="px-4 py-3">Hash</th>
                <th scope="col" class="px-4 py-3">Mined on</th>
                <th scope="col" class="px-4 py-3">Txns</th>
                <th scope="col" class="px-4 py-3">Size</th>
                <th scope="col" class="px-4 py-3">Output (ZEC)</th>
            </tr>
            </thead>
    <tbody>
      <%= for block <- @block_cache do %>
            <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-indigo-600 hover:text-indigo-500 dark:text-white dark:hover:text-white">
            <a href='/blocks/<%= block["height"] %>'>
                <%= block["height"] %>
              </td>
            </a>
            <td class="px-4 py-4 whitespace-nowrap">
                    <a href='/blocks/<%= block["hash"] %>'>
                    <%= block["hash"] %>
                    </a>
              </td>
              <td class="px-4 py-4 whitespace-nowrap">
                <%= block["time"] %>
              </td>
             <td class="px-4 py-4 whitespace-nowrap">
                <%= block["tx_count"] %>
              </td>
            <td class="px-4 py-4 whitespace-nowrap">
                <%= block["size"] %>
              </td>
             <td class="px-4 py-4 whitespace-nowrap">
                <%= block["output_total"] %>
              </td>

            </tr>
            <% end %>
    </tbody>
    </table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    case Cachex.get(:app_cache, "block_cache") do
      {:ok, info} ->
        {:ok, assign(socket, :block_cache, info)}

      {:error, _reason} ->
        {:ok, assign(socket, :block_cache, "loading...")}
    end
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:ok, info} = Cachex.get(:app_cache, "block_cache")
    {:noreply, assign(socket, :block_cache, info)}
  end
end
