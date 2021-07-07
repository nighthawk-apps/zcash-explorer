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

  def format_zec(value) when value != nil do
    float_value = (value + 0.0) |> :erlang.float_to_binary([:compact, {:decimals, 10}])
    float_value <> " " <> "ZEC"
  end

  def format_zec(value) when value == nil do
    ""
  end

  # functions to get the label for 
  # shielding  tx without vjoinsplit
  def get_shielded_pool_label(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) > 0 
      and length(tx.vout) == 0 
      and length(tx.vShieldedOutput) > 0 
      and (tx.valueBalance) < 0.0 
      do
        IO.inspect("38")
    "Transferred to shielded pool"
  end


  # handle when  vjoinsplit is present ( indicated legacy transaction)
  # 1
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) > 0 and length(tx.vin) > 0 do
    IO.inspect("47")
    "Transferred to shielded pool"
  end

  # handle when and vjoinsplit is present  and vin == 0 .. 
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) > 0 and length(tx.vin) == 0 do
    IO.inspect("54")
    "Transferred from shielded pool"
  end


# handle mixed tx
  def get_shielded_pool_label(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) > 0 
      and length(tx.vShieldedOutput) > 0
      and tx.valueBalance < 0.0
      do
        IO.inspect("68")
    "Transferred to shielded pool"
  end


  # handle public tx
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) == 0 and length(tx.vin) > 0 do
    IO.inspect("76")
    "Transferred from/to shielded pool"
  end


  # 3 with value balance 
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) == 0 and length(tx.vin) == 0 and
             length(tx.vout) > 0 and tx.valueBalance > 0 do
    IO.inspect("85")
    "Transferred from shielded pool"
  end

  # 4 shielded
  def get_shielded_pool_label(tx)
      when tx.vjoinsplit != nil and length(tx.vjoinsplit) == 0 and length(tx.vin) == 0 and
             length(tx.vout) == 0 and tx.valueBalance > 0 do
     IO.inspect("93")
    "Transferred from shielded pool"
  end



  # mixed 
   def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) > 0 
      and length(tx.vShieldedOutput) > 0
      and tx.valueBalance < 0.0
      do
        abs(tx.valueBalance)
  end



   def get_shielded_pool_value(tx)
    when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) > 0 
      and length(tx.vout) == 0 
      and length(tx.vShieldedOutput) > 0 
      and (tx.valueBalance) < 0.0 
      do
        abs(tx.valueBalance)
  end



  # 1
  def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) > 0 
      and length(tx.vin) > 0 do
    Map.get(tx, :vjoinsplit) |> Enum.reduce(0, fn x, acc -> Map.get(x, :vpub_old) + acc end)
  end


  # 3 
  def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) == 0 
      and length(tx.vout) > 0 
      and tx.valueBalance > 0 do
    abs(tx.valueBalance)
  end


  # 4 
  def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) > 0 
      and length(tx.vin) == 0 
      and length(tx.vout) == 0 
      do
    
    val = tx
    |> Map.get(:vjoinsplit)
    |> List.flatten()
    |> Enum.reduce(0, fn x, acc -> Map.get(x, :vpub_new) + acc end)
    |> Kernel.+(0.0)
    abs(val)
  end



  # 4 
  def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) > 0 
      and length(tx.vin) == 0 
      and length(tx.vout) > 0 
      do
    
    val = tx
    |> Map.get(:vout)
    |> List.flatten()
    |> Enum.reduce(0, fn x, acc -> Map.get(x, :value) + acc end)
    |> Kernel.+(0.0)
    abs(val)
  end



  # 4 
  def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) == 0 
      and length(tx.vout) == 0 
      and tx.valueBalance > 0 do
    abs(tx.valueBalance)
  end


  # handle public tx
  def get_shielded_pool_value(tx)
      when 
      tx.vjoinsplit != nil 
      and length(tx.vjoinsplit) == 0 
      and length(tx.vin) > 0 do
    0.00
  end


end
