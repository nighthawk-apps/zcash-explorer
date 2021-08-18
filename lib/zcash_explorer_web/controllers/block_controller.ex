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
        height = block_data.height

        render(conn, "index.html",
          block_data: block_data,
          block_subsidy: nil,
          page_title: "Zcash block #{height}"
        )

      n when n > 250 ->
        render(conn, "basic_block.html",
          block_data: basic_block_data,
          page_title: "Zcash block #{hash}"
        )
    end
  end

  def index(conn, %{"date" => date}) do
    max_concurrency = System.schedulers_online() * 2
    now = NaiveDateTime.utc_now() |> Timex.beginning_of_day()
    parsed_date = Timex.parse!(date, "{YYYY}-{0M}-{D}")
    diff = Timex.diff(parsed_date, now, :day)

    if diff > 0 do
      conn
      |> put_status(:not_found)
      |> put_view(ZcashExplorerWeb.ErrorView)
      |> render(:invalid_input)
    end

    previous = Timex.shift(parsed_date, days: -1) |> Timex.format!("{YYYY}-{0M}-{D}")
    next = Timex.shift(parsed_date, days: 1) |> Timex.format!("{YYYY}-{0M}-{D}")
    first_block_date = "2016-10-28"
    disable_previous = if first_block_date == date, do: true, else: false

    disable_next =
      if Timex.today() |> Timex.format!("{YYYY}-{0M}-{D}") == date, do: true, else: false

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

        render(
          conn,
          "blocks.html",
          blocks_data: blocks_data,
          date: date,
          disable_next: disable_next,
          disable_previous: disable_previous,
          next: next,
          previous: previous,
          page_title: "Zcash blocks mined on #{date}"
        )
    end
  end

  def index(conn, _params) do
    max_concurrency = System.schedulers_online() * 2
    today = Timex.today()
    high = DateTime.utc_now() |> DateTime.to_unix()
    low = DateTime.utc_now() |> Timex.beginning_of_day() |> Timex.to_unix()
    disable_next = true
    disable_previous = false
    previous = Timex.shift(today, days: -1)

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

        render(conn, "blocks.html",
          blocks_data: blocks_data,
          date: today,
          disable_next: disable_next,
          disable_previous: disable_previous,
          previous: previous,
          page_title: "Zcash latest blocks"
        )
    end
  end
end
