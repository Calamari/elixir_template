defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      # Assets bundling
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},

      # HTTP Client
      {:finch, "~> 0.13"},

      # HTTP server
      {:plug_cowboy, "~> 2.5"},

      # Phoenix
      {:phoenix, "~> 1.7.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.19.0"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:jason, "~> 1.4"},

      # Database
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},

      # PostgreSQL PostGIS extension
      {:geo_postgis, "~> 3.4"},

      # Authentication
      {:ueberauth, "~> 0.6"},
      {:ueberauth_identity, "~> 0.3"},
      {:guardian, "~> 2.1"},
      {:bcrypt_elixir, "~> 3.0"},
      {:secure_random, "~> 0.5"},

      # Authorization
      {:bodyguard, "~> 2.4"},

      # Translation
      {:gettext, "~> 0.18"},

      # HTML Parsing
      {:floki, ">= 0.30.0", only: :test},

      # Testing
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},

      # Test factories
      {:ex_machina, "~> 2.7", only: :test},
      {:faker, "~> 0.16", only: :test},

      # Test coverage
      {:excoveralls, "~> 0.14", only: :test},

      # Linting
      {:credo, "~> 1.5", only: [:dev, :test], override: true},
      {:credo_envvar, "~> 0.1", only: [:dev, :test], runtime: false},
      {:credo_naming, "~> 2.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},

      # Security check
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: true},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},

      # Email
      {:bamboo, "~> 2.3"},
      {:bamboo_phoenix, "~> 1.0"},

      # Error tracking
      {:honeybadger, "~> 0.1"},

      # Telemetry
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
