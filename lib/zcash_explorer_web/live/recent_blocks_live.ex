defmodule ZcashExplorerWeb.RecentBlocksLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="shadow overflow-hidden border-b border-gray-200 rounded-lg overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-white-500">
            <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Height</th>
                <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Hash</th>                
                <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Mined on</th>
                <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Txns</th>
                <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Size</th>
                <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Output (ZEC)</th>
            </tr>
            </thead>
  <tbody class="bg-white-500 divide-y divide-gray-200">
      <%= for block <- @block_cache do %>
            <tr>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-midnight-500">
            <a href='/blocks/<%= block["height"] %>'>
                <%= block["height"] %>
              </td>
            </a>
            <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                    <a href='/blocks/<%= block["hash"] %>'>
                    <%= block["hash"] %>
                    </a>
              </td>              
              <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= block["time"] %>
              </td> 
             <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= block["tx_count"] %>
              </td> 
            <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= block["size"] %>
              </td>  
             <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= block["output_total"] %>
              </td>               
                   
            </tr>                                           
            <% end %>
    </tbody>
</table>
<nav class="bg-white-500 px-4 py-3 flex items-center justify-between border-t border-gray-200 px-4">
    <div class="flex-1 flex justify-between sm:justify-end">
        <a href="/blocks" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
        View More
        </a>
    </div>
</nav>
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

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:ok, info} = Cachex.get(:app_cache, "block_cache")
    {:noreply, assign(socket, :block_cache, info)}
  end
end
