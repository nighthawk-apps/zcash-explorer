defmodule ZcashExplorerWeb.BlockView do
  use ZcashExplorerWeb, :view

  def mined_time(nil) do
    "Not yet mined"
  end

  def mined_time(timestamp) do
    abs = timestamp |> Timex.from_unix() |> Timex.format!("{ISOdate} {ISOtime}")
    rel = timestamp |> Timex.from_unix() |> Timex.format!("{relative}", :relative)
    abs <> " " <> "(#{rel})"
  end

  def mined_time_without_rel(timestamp) do
    timestamp |> Timex.from_unix() |> Timex.format!("{ISOdate} {ISOtime}")
  end

  def mined_time_rel(timestamp) do
    rel = timestamp |> Timex.from_unix() |> Timex.format!("{relative}", :relative)
  end

  def transaction_count(txs) do
    txs |> length
  end

  def vin_count(txs) do
    txs |> Enum.reduce(0, fn x, acc -> length(x.vin) + acc end)
  end

  def vout_count(txs) do
    txs |> Enum.reduce(0, fn x, acc -> length(x.vout) + acc end)
  end

  def is_coinbase_tx?(tx) when tx.vin == [] do
    false
  end

  def is_coinbase_tx?(tx) when length(tx.vin) > 0 do
    first_tx = tx.vin |> List.first()

    case Map.fetch(first_tx, :coinbase) do
      {:ok, nil} -> false
      {:ok, value} -> true
      {:error, _reason} -> false
    end
  end

  def mined_by(txs) do
    first_trx = txs |> List.first()

    if is_coinbase_tx?(first_trx) do
      first_trx
      |> Map.get(:vout)
      |> List.first()
      |> Map.get(:scriptPubKey)
      |> Map.get(:addresses)
      |> List.first()
    end
  end

  def input_total(txs) do
    [hd | tail] = txs

    tail
    |> Enum.map(fn x -> Map.get(x, :vin) end)
    |> List.flatten()
    |> Enum.reduce(0, fn x, acc -> Map.get(x, :value) + acc end)
    |> Kernel.+(0.0)
    |> :erlang.float_to_binary([:compact, {:decimals, 10}])
  end

  def output_total(txs) do
    txs
    |> Enum.map(fn x -> Map.get(x, :vout) end)
    |> List.flatten()
    |> Enum.reduce(0, fn x, acc -> Map.get(x, :value) + acc end)
    |> Kernel.+(0.0)
    |> :erlang.float_to_binary([:compact, {:decimals, 10}])
  end

  def tx_out_total(%Zcashex.Transaction{} = tx) do
    tx
    |> Map.get(:vout)
    |> List.flatten()
    |> Enum.reduce(0, fn x, acc -> Map.get(x, :value) + acc end)
    |> Kernel.+(0.0)
    |> :erlang.float_to_binary([:compact, {:decimals, 10}])
  end

  def tx_out_total(tx) when is_map(tx) do
    tx
    |> Map.get("vout")
    |> List.flatten()
    |> Enum.reduce(0, fn x, acc -> Map.get(x, "value") + acc end)
    |> Kernel.+(0.0)
    |> :erlang.float_to_binary([:compact, {:decimals, 10}])
  end

  # detect if a transaction is Public
  # https://z.cash/technology/ 
  def transparent_in_and_out(tx) do
    length(tx.vin) > 0 and length(tx.vout) > 0
  end

  def contains_sprout(tx) do
    length(tx.vjoinsplit) > 0
  end

  def get_joinsplit_count(tx) do
    length(tx.vjoinsplit)
  end

  def contains_sapling(tx) do
    value_balance = Map.get(tx, :valueBalance) || 0.0
    vshielded_spend = Map.get(tx, :vShieldedSpend) || []
    vshielded_output = Map.get(tx, :vShieldedOutput) || []
    value_balance != 0.0 and (length(vshielded_spend) > 0 || length(vshielded_output) > 0)
  end

  def is_shielded_tx?(tx) do
    !transparent_in_and_out(tx) and (contains_sprout(tx) or contains_sapling(tx))
  end

  def is_transparent_tx?(tx) do
    value_balance = Map.get(tx, :valueBalance) || 0.0
    vshielded_spend = Map.get(tx, :vShieldedSpend) || []
    vshielded_output = Map.get(tx, :vShieldedOutput) || []

    transparent_in_and_out(tx) && length(tx.vjoinsplit) == 0 && value_balance == 0.0 &&
      length(vshielded_spend) == 0 && length(vshielded_output) == 0
  end

  def is_mixed_tx?(tx) do
    t_in_or_out = length(tx.vin) > 0 or length(tx.vout) > 0
    t_in_or_out and (contains_sprout(tx) || contains_sapling(tx))
  end

  def is_shielding(tx) do
    tin_and_zout = length(tx.vin) > 0 and length(tx.vout) == 0
    tin_and_zout and (contains_sprout(tx) || contains_sapling(tx))
  end

  def is_deshielding(tx) do
    zin_and_tout = length(tx.vin) == 0 and length(tx.vout) > 0
    zin_and_tout and (contains_sprout(tx) || contains_sapling(tx))
  end

  def tx_type(tx) do
    cond do
      is_coinbase_tx?(tx) ->
        "coinbase"

      is_mixed_tx?(tx) ->
        cond do
          is_shielding(tx) -> "shielding"
          is_deshielding(tx) -> "deshielding"
          true -> "mixed"
        end

      is_shielded_tx?(tx) ->
        "shielded"

      is_transparent_tx?(tx) ->
        "transparent"

      true ->
        "unknown"
    end
  end

  # TODO : complete later
  def block_subsidy(block_subsidy) do
    case block_subsidy do
      %{"founders" => founders, "miner" => miner} when is_map(block_subsidy) ->
        %{"founder" => founders, "miner" => miner}

      %{"founders" => 0.0, "fundingstreams" => fundingstreams, "miner" => miner}
      when is_map(block_subsidy) ->
        %{}
    end
  end
end
