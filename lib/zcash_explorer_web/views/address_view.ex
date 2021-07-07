defmodule ZcashExplorerWeb.AddressView do
  use ZcashExplorerWeb, :view

  def zatoshi_to_zec(zatoshi) do
    zatoshi_per_zec = :math.pow(10, -8)
    zatoshi_per_zec * zatoshi
  end

  def spend_zatoshi(received, balance) do
    (received - balance) |> zatoshi_to_zec
  end

  def disable_next(end_block, latest_block) do
    end_block >= latest_block
  end

  def disable_previous(start_block) do
    start_block == 1
  end

  def previous_pagination(start_block, end_block) do
    s = start_block
    e = end_block
    diff = e - s
    e = s - 1
    s = e - diff
    s = if s <= 0, do: 1, else: s
    {s, e}
  end

  def next_pagination(start_block, end_block) do
    s = start_block
    e = end_block
    diff = e - s
    s = e + 1
    e = s + diff
    {s, e}
  end
end
