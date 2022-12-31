defmodule ZcashExplorerWeb.NodesLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <div class="shadow overflow-hidden border-gray-200 rounded-lg overflow-x-auto">
    <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
      <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
    <tr>
         <th scope="col" class="px-6 py-3">Address</th>
         <th scope="col" class="px-4 py-3">Version</th>
          <th scope="col" class="px-4 py-3">Block Height</th>
        </tr>
       </thead>
       <tbody class="bg-white-500 divide-y divide-gray-200">
       <%= for node <- @zcash_nodes do %>
       <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
       <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-indigo-600 hover:text-indigo-500 animate-pulse dark:text-white dark:hover:text-white">
       <%= node["addr"] %>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
            <%= node["subver"] %>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium">
            <%= node["synced_blocks"] %>
        </td>
       </tr>
      <% end %>
    </tbody>
    </table>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 5000)

    case Cachex.get(:app_cache, "zcash_nodes") do
      {:ok, zcash_nodes} ->
        {:ok, assign(socket, :zcash_nodes, zcash_nodes)}

      {:error, _reason} ->
        {:ok, assign(socket, :zcash_nodes, "loading...")}
    end
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    {:ok, zcash_nodes} = Cachex.get(:app_cache, "zcash_nodes")
    {:noreply, assign(socket, :zcash_nodes, zcash_nodes)}
  end
end
