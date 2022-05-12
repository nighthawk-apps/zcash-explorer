defmodule ZcashExplorerWeb.BlockChainInfoLive do
  
  use ZcashExplorerWeb, :live_view
  import Phoenix.LiveView.Helpers
  @impl true
  def render(assigns) do
    ~L"""
    <div>
    <dl class="mt-5 grid grid-cols-1 gap-5 sm:grid-cols-3">
    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
      <dt class="text-sm font-medium text-gray-500 truncate">
        Blocks
      </dt>
      <dd class="mt-1 text-3xl font-semibold text-gray-900">
        <%= @blockchain_info["blocks"] %>
      </dd>
    </div>

    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
      <dt class="text-sm font-medium text-gray-500 truncate">
        Commitments
      </dt>
      <dd class="mt-1 text-3xl font-semibold text-gray-900">
        <%= @blockchain_info["commitments"] %>
      </dd>
    </div>

    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
      <dt class="text-sm font-medium text-gray-500 truncate">
        Difficulty
      </dt>
      <dd class="mt-1 text-3xl font-semibold text-gray-900">
        <%= @blockchain_info["difficulty"] %>
      </dd>
    </div>

    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
      <dt class="text-sm font-medium text-gray-500 truncate">
        Sprout pool
      </dt>
      <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= sprout_value(@blockchain_info["valuePools"]) %> ZEC
      </dd>
    </div>

    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
      <dt class="text-sm font-medium text-gray-500 truncate">
        Sapling pool
      </dt>
      <dd class="mt-1 text-3xl font-semibold text-gray-900">
          <%= sapling_value(@blockchain_info["valuePools"]) %> ZEC
      </dd>
    </div>

    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
    <dt class="text-sm font-medium text-gray-500 truncate">
      Orchard pool
    </dt>
    <dd class="mt-1 text-3xl font-semibold text-gray-900">
        <%= orchard_value(@blockchain_info["valuePools"]) %> ZEC
    </dd>
  </div>

    <div class="px-4 py-5 bg-white shadow rounded-lg overflow-hidden sm:p-6">
      <dt class="text-sm font-medium text-gray-500 truncate">
        zcashd version
      </dt>
      <dd class="mt-1 text-3xl font-semibold text-gray-900">
      <%= @blockchain_info["build"] %>
      </dd>
    </div>
    </dl>
    </div>


    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 5000)

    case Cachex.get(:app_cache, "metrics") do
      {:ok, info} ->
        {:ok, %{"build" => build}} = Cachex.get(:app_cache, "info")
        info = Map.put(info, "build", build)
        {:ok, assign(socket, :blockchain_info, info)}

      {:error, _reason} ->
        {:ok, assign(socket, :blockchain_info, "loading...")}
    end
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 15000)
    {:ok, info} = Cachex.get(:app_cache, "metrics")
    {:ok, %{"build" => build}} = Cachex.get(:app_cache, "info")
    info = Map.put(info, "build", build)
    {:noreply, assign(socket, :blockchain_info, info)}
  end

  defp sprout_value(value_pools) do
    value_pools |> get_value_pools() |> Map.get("sprout")
  end

  defp sapling_value(value_pools) do
    value_pools |> get_value_pools() |> Map.get("sapling")
  end

  defp orchard_value(value_pools) do
    value_pools |> get_value_pools |> Map.get("orchard")
  end

  defp get_value_pools(value_pools) do
    Enum.map(value_pools, fn %{"id" => name, "chainValue" => value} -> {name, value} end)
    |> Map.new()
  end
end
