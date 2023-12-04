defmodule ZcashExplorer.MixProject do
  use Mix.Project

  def project do
    [
      app: :zcash_explorer,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ZcashExplorer.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :cachex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_psql_extras, "~> 0.7.14"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6.5"},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:observer_cli, "~> 1.6"},
      {:cachex, "~> 3.3"},
      {:phoenix_live_view, "~> 0.17.9"},
      {:floki, ">= 0.27.0", only: :test},
      {:zcashex, github: "nighthawk-apps/zcashex"},
      {:timex, "~> 3.0"},
      {:sizeable, "~> 1.0"},
      {:eqrcode, "~> 0.1.8"},
      {:contex, "~> 0.3.0"},
      {:muontrap, "~> 0.6.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
