defmodule ZcashExplorerWeb.RawMempoolLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
  <div class="shadow overflow-hidden border-b border-gray-200 rounded-lg overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-white-500">
      <tr>
         <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Tx ID</th>
         <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Block</th>
          <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Time</th>
          <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Fee</th>
          <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Size</th>
          <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Currentpriority</th>
        </tr>
       </thead>
       <tbody class="bg-white-500 divide-y divide-gray-200">
       <%= for tx <- @raw_mempool do %>
        <tr class="hover:bg-indigo-50">
        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-indigo-600 hover:text-indigo-500">
          <a href='/transactions/<%= tx["txid"] %>'>
               <%= tx["txid"] %>
          </a>
        </td>  
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
            <%= tx["info"]["height"] %>
          </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
          <%= ZcashExplorerWeb.BlockView.mined_time_rel(tx["info"]["time"]) %>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
         <%= ZcashExplorerWeb.TransactionView.format_zec(tx["info"]["fee"]) %>
        </td>     
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
          <%= tx["info"]["size"] %>
        </td>
        <td class="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-500 hover:text-gray-600">
         <%= tx["info"]["currentpriority"] %>
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
    if connected?(socket), do: Process.send_after(self(), :update, 30000)

    case Cachex.get(:app_cache, "raw_mempool") do
      {:ok, mempool} ->
        {:ok, assign(socket, :raw_mempool, mempool)}

      {:error, _reason} ->
        {:ok, assign(socket, :raw_mempool, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 30000)
    {:ok, mempool} = Cachex.get(:app_cache, "raw_mempool")
    {:noreply, assign(socket, :raw_mempool, mempool)}
  end
end
