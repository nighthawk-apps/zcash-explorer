defmodule ZcashExplorerWeb.OrchardPoolLive do
    use ZcashExplorerWeb, :live_view
    import Phoenix.LiveView.Helpers
    @impl true
    def render(assigns) do
      ~L"""
      <p class="text-2xl font-semibold text-gray-900 dark:dark:bg-slate-800 dark:text-slate-100">
      <%= orchard_value(@blockchain_info["valuePools"]) %> ZEC
      </p>
      """
    end
  
    @impl true
    def mount(_params, _session, socket) do
      if connected?(socket), do: Process.send_after(self(), :update, 15000)
  
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

    defp orchard_value(value_pools) do
        value_pools |> get_value_pools |> Map.get("orchard")
      end
    
    defp get_value_pools(value_pools) do
        Enum.map(value_pools, fn %{"id" => name, "chainValue" => value} -> {name, value} end)
        |> Map.new()
    end


  end
  