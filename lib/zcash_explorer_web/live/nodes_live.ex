defmodule ZcashExplorerWeb.NodesLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <div class="shadow overflow-hidden border-b border-gray-200 rounded-lg overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-white-500">
      <tr>
         <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Address</th>
         <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Version</th>
          <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Block Height</th>
        </tr>
       </thead>
       <tbody class="bg-white-500 divide-y divide-gray-200">
       <%= for node <- @zcash_nodes do %>
        <tr class="hover:bg-indigo-50">
        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-indigo-500">
               <%= node["addr"] %>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
            <%= node["subver"] %>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
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
