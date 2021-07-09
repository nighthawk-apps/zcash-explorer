defmodule ZcashExplorerWeb.BlockController do
  use ZcashExplorerWeb, :controller

  def get_block(conn, %{"hash" => hash}) do
    {:ok, basic_block_data} = Zcashex.getblock(hash, 1)

    case length(basic_block_data["tx"]) do
      0 ->
        {:error, :no_tx}

      n when n <= 250 ->
        {:ok, block_data} = Zcashex.getblock(hash, 2)
        block_data = Zcashex.Block.from_map(block_data)
        render(conn, "index.html", block_data: block_data, block_subsidy: nil)

      n when n > 250 ->
        render(conn, "basic_block.html", block_data: basic_block_data)
    end

    # TODO : display block subsidy
    # {:ok, block_subsidy} = Zcashex.getblocksubsidy(block_data.height)
    # IO.inspect(block_subsidy)
  end

  def index(conn, %{"date" => date}) do
    max_concurrency = System.schedulers_online() * 2
    parsed_date = Timex.parse!(date, "{YYYY}-{0M}-{D}")
    high = parsed_date |> Timex.end_of_day() |> Timex.to_unix()
    low = parsed_date |> Timex.beginning_of_day() |> Timex.to_unix()

    case Zcashex.getblockhashes(high, low, true, false) do
      {:ok, blocks} ->
        blocks_data =
          blocks
          |> Task.async_stream(fn block -> Zcashex.getblockheader(block) end,
            max_concurrency: max_concurrency,
            ordered: false
          )
          |> Enum.to_list()
          |> Enum.map(fn {task, {:ok, res}} -> res end)
          |> Enum.reverse()

        render(conn, "blocks.html", blocks_data: blocks_data, date: date)
    end
  end

  def index(conn, _params) do
    max_concurrency = System.schedulers_online() * 2
    today = Timex.today()
    high = DateTime.utc_now() |> DateTime.to_unix()
    low = DateTime.utc_now() |> Timex.beginning_of_day() |> Timex.to_unix()

    case Zcashex.getblockhashes(high, low, true, false) do
      {:ok, blocks} ->
        blocks_data =
          blocks
          |> Task.async_stream(fn block -> Zcashex.getblockheader(block) end,
            max_concurrency: max_concurrency,
            ordered: false
          )
          |> Enum.to_list()
          |> Enum.map(fn {task, {:ok, res}} -> res end)
          |> Enum.reverse()

        render(conn, "blocks.html", blocks_data: blocks_data, date: today)
    end
  end
end
