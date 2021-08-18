defmodule ZcashExplorerWeb.RecentTransactionsLive do
  use Phoenix.LiveView

  @impl true
  def render(assigns) do
    ~L"""
    <div class="shadow overflow-hidden border-b border-gray-200 rounded-lg overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead  class="bg-white-500">
            <tr>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Transaction ID</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Block#</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Time (UTC )</th>
                <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">Output (ZEC) </th>
                <th scope="col" class="px-4 py-3 text-left text-xs font-medium text-midnight-500 uppercase tracking-wider">TX Type</th>
            </tr>
            </thead>
    <tbody class="bg-white-500 divide-y divide-gray-200">
      <%= for tx <- @transaction_cache do %>
            <tr class="hover:bg-indigo-50">
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-indigo-600 hover:text-indigo-500">
                <a href='/transactions/<%= tx["txid"] %>'>
                  <%= tx["txid"] %>
                </a>
              </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
              <a href='/blocks/<%= tx["block_height"] %>'>
                <%= tx["block_height"] %>
              </a>
            </td>

              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= tx["time"] %>
              </td>
             <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-500">
                <%= tx["tx_out_total"] %>
             </td>
             <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  <%= if tx["type"] == "coinbase" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-yellow-400 text-gray-900 capitalize">
                    💰 Coinbase
                  </span>
                  <% end %>
                  <%= if tx["type"] == "shielded" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-green-400 text-gray-900 capitalize">
                    🛡 Shielded
                  </span>
                  <% end %>
                  <%= if tx["type"] == "transparent" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-red-200 text-gray-900 capitalize">
                    🔍 Public
                  </span>
                  <% end %>
                  <%= if tx["type"] == "shielding" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-red-50 text-gray-900 capitalize">
                    Shielding ( t-z )
                  </span>
                  <% end %>
                  <%= if tx["type"] == "deshielding" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-red-50 text-gray-900 capitalize">
                    Deshielding ( z-t )
                  </span>
                  <% end %>
                  <%= if tx["type"] == "mixed" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-gray-200 text-gray-900 capitalize">
                    Mixed
                  </span>
                  <% end %>
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

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1000)
    {:ok, info} = Cachex.get(:app_cache, "transaction_cache")
    {:noreply, assign(socket, :transaction_cache, info)}
  end
end
