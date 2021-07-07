defmodule ZcashExplorerWeb.BlockController do
  use ZcashExplorerWeb, :controller

  def get_block(conn, %{"hash" => hash}) do
  	{:ok, basic_block_data} = Zcashex.getblock(hash, 1)
  	case length(basic_block_data["tx"]) do 
  		0 ->
           { :error, :no_tx }
        n when n <= 250 ->
           {:ok, block_data} = Zcashex.getblock(hash, 2)
           block_data = Zcashex.Block.from_map(block_data)
           render(conn, "index.html", block_data: block_data, block_subsidy: nil)
        n when n > 250 ->
           render(conn, "basic_block.html", block_data: basic_block_data)
  	end
  	#TODO : display block subsidy
    # {:ok, block_subsidy} = Zcashex.getblocksubsidy(block_data.height)
    # IO.inspect(block_subsidy)
  end
end
