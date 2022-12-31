defmodule ZcashExplorerWeb.RecentTransactionsLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <div class="shadow overflow-hidden border-gray-200 rounded-lg overflow-x-auto">
    <table class="w-full text-sm text-left text-gray-500 dark:text-gray-400">
    <thead class="text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400">
    <tr>
                <th scope="col" class="px-6 py-3">Transaction ID</th>
                <th scope="col" class="px-6 py-3">Block#</th>
                <th scope="col" class="px-6 py-3">Time (UTC )</th>
                <th scope="col" class="px-6 py-3">Public Output (ZEC) </th>
                <th scope="col" class="px-4 py-3">TX Type</th>
            </tr>
            </thead>
    <tbody>
      <%= for tx <- @transaction_cache do %>
      <tr class="bg-white border-b dark:bg-gray-800 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-600">
      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-indigo-600 hover:text-indigo-500 dark:text-white dark:hover:text-white">
                <a href='/transactions/<%= tx["txid"] %>'>
                  <%= tx["txid"] %>
                </a>
              </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <a href='/blocks/<%= tx["block_height"] %>'>
                <%= tx["block_height"] %>
              </a>
            </td>

              <td class="px-6 py-4 whitespace-nowrap">
                <%= tx["time"] %>
              </td>
             <td class="px-6 py-4 whitespace-nowrap">
                <%= tx["tx_out_total"] %>
             </td>
             <td class="px-6 py-4 whitespace-nowrap">
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
                  <%= if  tx["type"] == "unknown" do %>
                  <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-s font-medium bg-gray-200 text-gray-900 capitalize">
                    Unknown
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
