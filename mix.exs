defmodule CatOnDuty.MixProject do
  use Mix.Project

  def project do
    [
      app: :cat_on_duty,
      version: "1.2.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix, :ex_unit], plt_core_path: "priv/dialyzer/", plt_local_path: "priv/dialyzer/"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CatOnDuty.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :xmerl]
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
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.12"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0.1"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:ecto_sqlite3_extras, "~> 1.2"},
      {:error_tracker, "~> 0.5"},
      {:telemetry, "~> 1.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.5"},
      {:oban, "~> 2.18"},
      {:telegex, "~> 1.8"},
      {:finch, "~> 0.19"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:ecto_erd, "~> 0.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.1", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:temp, "~> 0.4", only: [:dev, :test]},
      {:floki, "~> 0.36", only: :test},
      {:exvcr, "~> 0.15", only: :test}
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
      "ecto.reset": ["ecto.drop", "ecto.setup"]
    ]
  end
end
