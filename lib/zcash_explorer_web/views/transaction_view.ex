defmodule ZcashExplorerWeb.TransactionView do
  use ZcashExplorerWeb, :view

  def vin_vout_count(tx) do
    vin_count = length(tx.vin)
    vout_count = length(tx.vout)
    "#{vin_count} / #{vout_count}"
  end

  def vin_count(vin) do
    length(vin)
  end

  def vout_count(vout) do
    length(vout)
  end

  def format_zec(value) when value == nil do
    ""
  end

  def format_zec(value) when value != nil do
    zcash_network = Application.get_env(:zcash_explorer, Zcashex)[:zcash_network]
    currency = if zcash_network == "mainnet", do: "ZEC", else: "TAZ"
    float_value = (value + 0.0) |> :erlang.float_to_binary([:compact, {:decimals, 10}])
    float_value <> " " <> currency
  end

  def orchard_actions(tx) do
    case tx do
      %{orchard: %{actions: actions}} when is_list(actions) -> length(actions)
      _ -> 0
    end
  end

  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 and
             tx.version == 5 and
             tx.orchard.actions != nil and
             length(tx.orchard.actions) > 0 and
             tx.orchard.valueBalance > 0 do
    "Transferred from shielded pool"
  end

  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 and
             tx.version == 5 and
             tx.orchard.actions != nil and
             length(tx.orchard.actions) > 0 and
             tx.orchard.valueBalance < 0 do
    "Transferred to shielded pool"
  end

  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance < 0.0 and
             tx.version == 5 do
    "Transferred from/to shielded pool"
  end

  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) > 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    "Transferred from shielded pool"
  end

  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    "Transferred from/to shielded pool"
  end

  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) > 0 and
             tx.valueBalance == 0.0 do
    "Transferred from/to shielded pool"
  end

  # functions to get the label for
  # tx with 0 tx fee ?
  # TODO : do more research on how this is possible ?
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             tx.valueBalance < 0.0 do
    "Transferred to shielded pool"
  end

  # handle when  vjoinsplit is present ( indicated legacy transaction)
  # 1
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) > 0 and length(tx.vin) > 0 do
    "Transferred to shielded pool"
  end

  # handle when and vjoinsplit is present  and vin == 0 ..
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) > 0 and length(tx.vin) == 0 do
    "Transferred from shielded pool"
  end

  # handle mixed tx
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vShieldedOutput) > 0 and
             tx.valueBalance < 0.0 do
    "Transferred to shielded pool"
  end

  # handle public tx
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) == 0 and length(tx.vin) > 0 do
    "Transferred from/to shielded pool"
  end

  # 3 with value balance
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) == 0 and length(tx.vin) == 0 and
             length(tx.vout) > 0 and tx.valueBalance > 0 do
    "Transferred from shielded pool"
  end

  # 4 shielded
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) == 0 and length(tx.vin) == 0 and
             length(tx.vout) == 0 and tx.valueBalance > 0 do
    "Transferred from shielded pool"
  end

  # 247aaa9a1307ab094cc077123867b019a20aa35cc7e394d7607127e146d54922
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 and
             tx.version == 5 and
             tx.orchard.actions != nil and
             length(tx.orchard.actions) > 0 do
    tx.orchard.valueBalance
  end

  #
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance < 0.0 and
             tx.version == 5 do
    0
  end

  #
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) > 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    Map.get(tx, :vjoinsplit) |> Enum.reduce(0, fn x, acc -> Map.get(x, :vpub_old) + acc end)
  end

  # 0 feed tx ( not legacy )
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) > 0 and
             tx.valueBalance == 0.0 do
    0.0
  end

  # mixed
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vShieldedOutput) > 0 and
             tx.valueBalance < 0.0 do
    abs(tx.valueBalance)
  end

  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             tx.valueBalance < 0.0 do
    abs(tx.valueBalance)
  end

  # 1
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) > 0 and
             length(tx.vin) > 0 do
    Map.get(tx, :vjoinsplit) |> Enum.reduce(0, fn x, acc -> Map.get(x, :vpub_old) + acc end)
  end

  # 3
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) > 0 and
             tx.valueBalance > 0 do
    abs(tx.valueBalance)
  end

  # 4
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) > 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 do
    val =
      tx
      |> Map.get(:vjoinsplit)
      |> List.flatten()
      |> Enum.reduce(0, fn x, acc -> Map.get(x, :vpub_new) + acc end)
      |> Kernel.+(0.0)

    abs(val)
  end

  # 4 Deshielding legacy
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) > 0 and
             length(tx.vin) == 0 and
             length(tx.vout) > 0 do
    val =
      tx
      |> Map.get(:vjoinsplit)
      |> List.flatten()
      |> Enum.reduce(0, fn x, acc -> Map.get(x, :vpub_new) + acc end)
      |> Kernel.+(0.0)

    abs(val)
  end

  # 4
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             tx.valueBalance > 0 do
    abs(tx.valueBalance)
  end

  # handle public tx
  def get_shielded_pool_value(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 do
    0.00
  end

  def tx_in_total(tx) when is_map(tx) do
    tx.vin |> Enum.reduce(0, fn x, acc -> x.value + acc end)
  end

  def tx_out_total(tx) when is_map(tx) do
    tx.vout |> Enum.reduce(0, fn x, acc -> x.value + acc end)
  end

  def transparent_tx_fee(public_tx) do
    fee = tx_in_total(public_tx) - tx_out_total(public_tx)
    fee |> format_zec()
  end

  def vjoinsplit_vpub_old_total(tx) when is_map(tx) do
    tx.vjoinsplit |> Enum.reduce(0, fn x, acc -> x.vpub_old + acc end)
  end

  def vjoinsplit_vpub_new_total(tx) when is_map(tx) do
    tx.vjoinsplit |> Enum.reduce(0, fn x, acc -> x.vpub_new + acc end)
  end

  def shielding_tx_fee(tx) when is_map(tx) and length(tx.vjoinsplit) > 0 do
    fee = tx_in_total(tx) - vjoinsplit_vpub_old_total(tx)
    fee |> format_zec()
  end

  def shielding_tx_fee(tx) when is_map(tx) and length(tx.vjoinsplit) == 0 and tx.version <= 4 do
    fee = tx_in_total(tx) - abs(tx.valueBalance)
    fee |> format_zec()
  end

  # example 1b0f70849ff66402553d696e154c3db1f54cf1512d19a2683f4576f5f990a69d
  def shielding_tx_fee(tx)
      when is_map(tx) and length(tx.vjoinsplit) == 0 and tx.version == 5 and
             tx.orchard.valueBalance == 0 do
    fee = tx_in_total(tx) - abs(tx.valueBalance)
    fee |> format_zec()
  end

  # c7eb2ac6252fd266a74f5266ed9c1e585571ae941901480053f7886330829dea
  def shielding_tx_fee(tx) when is_map(tx) and length(tx.vjoinsplit) == 0 and tx.version == 5 do
    fee = tx_in_total(tx) - abs(tx.orchard.valueBalance)
    fee |> format_zec()
  end

  def deshielding_tx_fees(tx) when is_map(tx) and length(tx.vjoinsplit) > 0 do
    fee = vjoinsplit_vpub_new_total(tx) - tx_out_total(tx)
    fee |> format_zec()
  end

  #
  def deshielding_tx_fees(tx)
      when is_map(tx) and length(tx.vjoinsplit) == 0 and tx.version <= 4 do
    fee = tx.valueBalance - tx_out_total(tx)
    fee |> format_zec()
  end

  #
  def deshielding_tx_fees(tx)
      when is_map(tx) and length(tx.vjoinsplit) == 0 and tx.version == 5 and
             tx.orchard.valueBalance == 0 do
    fee = tx.valueBalance - tx_out_total(tx)
    fee |> format_zec()
  end

  # 2e6b1180f806af3b4e0b51604a4b846f881db3801a410486269bfda5cb39c716
  def deshielding_tx_fees(tx)
      when is_map(tx) and length(tx.vjoinsplit) == 0 and tx.version == 5 do
    fee = tx.orchard.valueBalance - tx_out_total(tx)
    fee |> format_zec()
  end

  # e145617c5d7d1646674da1d36540faff8e548738c0f500857e3230b35e85ca5f
  def unknown_tx_fees(tx)
      when tx.vjoinsplit != nil and
             tx.version == 5 and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    "¯\\_(ツ)_/¯"
  end

  def unknown_tx_fees(tx)
      when tx.vjoinsplit != nil and
             tx.version == 5 and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vout) > 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance < 0.0 do
    "¯\\_(ツ)_/¯"
  end

  def unknown_tx_fees(tx)
      when tx.vjoinsplit != nil and
             tx.version == 5 and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) > 0 and
             length(tx.vout) > 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    "¯\\_(ツ)_/¯"
  end

  def unknown_tx_fees(tx)
      when tx.vjoinsplit != nil and
             tx.version == 5 and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) > 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    "¯\\_(ツ)_/¯"
  end

  def unknown_tx_fees(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) == 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance == 0.0 do
    "¯\\_(ツ)_/¯"
  end

  def unknown_tx_fees(tx)
      when tx.vjoinsplit != nil and
             length(tx.vjoinsplit) == 0 and
             length(tx.vin) == 0 and
             length(tx.vout) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) > 0 and
             tx.valueBalance == 0.0 do
    fee = 0.0
    fee |> format_zec()
  end

  # exampple tx ( mainnet )
  # 872878da4a04b54d7134000d2f81d3bea3319cd946cab69a43699261415bb583
  def mixed_tx_fees(tx)
      when is_map(tx) and
             length(tx.vjoinsplit) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) > 0 and
             tx.valueBalance > 0 and
             length(tx.vin) > 0 and
             length(tx.vout) > 0 do
    fee = tx_in_total(tx) - tx_out_total(tx) + tx.valueBalance
    fee |> format_zec()
  end

  # exampple tx ( mainnet )
  # 00050f6582dba82305b2d5d25332445293f6cd784c829446704891167806a89f
  def mixed_tx_fees(tx)
      when is_map(tx) and
             length(tx.vjoinsplit) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) == 0 and
             tx.valueBalance < 0 and
             length(tx.vin) > 0 and
             length(tx.vout) > 0 do
    fee = tx_in_total(tx) - abs(tx.valueBalance) - tx_out_total(tx)
    fee |> format_zec()
  end

  # exampple tx ( mainnet )
  # 32aa7ca775e5d6ea94a6bea855a2fa6f97b208cb82fa75c9c6081cdf222cb658
  def mixed_tx_fees(tx)
      when is_map(tx) and
             length(tx.vjoinsplit) == 0 and
             length(tx.vShieldedOutput) > 0 and
             length(tx.vShieldedSpend) > 0 and
             tx.valueBalance < 0 and
             length(tx.vin) > 0 and
             length(tx.vout) > 0 do
    fee = tx_in_total(tx) - abs(tx.valueBalance) - tx_out_total(tx)
    fee |> format_zec()
  end
end
