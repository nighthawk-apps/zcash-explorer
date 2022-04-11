defmodule ZcashExplorerWeb.PriceLive do
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <dd class="ml-16 pb-6 flex items-baseline sm:pb-7">
    <p class="text-2xl font-semibold text-gray-900">
    $<%= @price["zcash"]["usd"] %>
    </p>
         <%= if  @price["zcash"]["usd_24h_change"] > 0  do %>
    <p class="ml-2 flex items-baseline text-sm font-semibold text-green-600">
          <!-- Heroicon name: solid/arrow-sm-up -->
          <svg class="self-center flex-shrink-0 h-5 w-5 text-green-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path fill-rule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L11 7.414V15a1 1 0 11-2 0V7.414L6.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
          </svg>
          <span class="sr-only">
            Increased by
          </span>
          <%= Float.ceil(@price["zcash"]["usd_24h_change"], 4) %> %
    </p>
     <% end %>

      <%= if  @price["zcash"]["usd_24h_change"] < 0  do %>
          <p class="ml-2 flex items-baseline text-sm font-semibold text-red-600">
          <!-- Heroicon name: solid/arrow-sm-down -->

          <svg class="self-center flex-shrink-0 h-5 w-5 text-red-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
            <path fill-rule="evenodd" d="M14.707 10.293a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 111.414-1.414L9 12.586V5a1 1 0 012 0v7.586l2.293-2.293a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
          
          <span class="sr-only">
            Decreased by
          </span>
          <%= Float.ceil(@price["zcash"]["usd_24h_change"], 4) %>%
    </p>
     <% end %>



    <div class="absolute bottom-0 inset-x-0 bg-gray-50 px-4 py-4 sm:px-6">
          <div class="text-sm">
            <a href="https://www.coingecko.com/en/coins/zcash" target="_blank" rel="noreferrer" class="font-medium text-indigo-600 hover:text-indigo-500"> View more<span class="sr-only"> View detailed price charts of Zcash.</span></a>
          </div>
    </div>
      </dd>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 3000)

    case Cachex.get(:app_cache, "price") do
      {:ok, price} ->
        {:ok, assign(socket, :price, price)}

      {:error, _reason} ->
        {:ok, assign(socket, :price, "updating...")}
    end
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 3000)
    {:ok, price} = Cachex.get(:app_cache, "price")
    {:noreply, assign(socket, :price, price)}
  end
end
