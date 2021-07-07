defmodule ZcashExplorer.Repo do
  use Ecto.Repo,
    otp_app: :zcash_explorer,
    adapter: Ecto.Adapters.Postgres
end
