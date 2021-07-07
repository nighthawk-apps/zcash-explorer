defmodule ZcashExplorerWeb.RecentTransactionsLive do
  use Phoenix.LiveView

  def render(assigns) do

    ~L"""
    <div class="shadow overflow-hidden border-b border-gray-200 rounded-lg overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead  class="bg-white-500">
            <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Block#</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Transaction ID</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Time (UTC )</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Size (bytes) </th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Output (ZEC) </th>
            </tr>
            </thead>
  <tbody class="bg-white-500 divide-y divide-gray-200">
      <%= for tx <- @transaction_cache do %>
            <tr>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
              <a href='/blocks/<%= tx["block_height"] %>'>
                <%= tx["block_height"] %>
              </a>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <a href='/transactions/<%= tx["txid"] %>'>
                  <%= tx["txid"] %>
                </a>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= tx["time"] %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= tx["size"] %>
              </td>
             <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= tx["tx_out_total"] %>
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

    case Cachex.get(:app_cache, "transaction_cache") do
      {:ok, info} ->
        {:ok, assign(socket, :transaction_cache, info)}

      {:error, _reason} ->
        {:ok, assign(socket, :transaction_cache, "loading...")}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:ok, info} = Cachex.get(:app_cache, "transaction_cache")
    {:noreply, assign(socket, :transaction_cache, info)}
  end
end
