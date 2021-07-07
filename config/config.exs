# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :zcash_explorer,
  ecto_repos: [ZcashExplorer.Repo]

# Configures the endpoint
config :zcash_explorer, ZcashExplorerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rVfb1mphofjIChVV5RIHW32JxP+aNNOGR4TaOrFSmEPhywkGmPjNHHj6QKCnMxDq",
  render_errors: [view: ZcashExplorerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ZcashExplorer.PubSub,
  live_view: [signing_salt: "a4lss9+vZQHOxErTzxjNU4IuhAaslE0Z"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
