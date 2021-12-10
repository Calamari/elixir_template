defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
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
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},

      # HTTP Client
      {:hackney, "~> 1.18"},

      # HTTP server
      {:plug_cowboy, "~> 2.5"},

      # Phoenix
      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.16.0"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:jason, "~> 1.2"},

      # Database
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},

      # PostgreSQL PostGIS extension
      {:geo_postgis, "~> 3.4"},

      # Authentication
      {:ueberauth, "~> 0.6"},
      {:ueberauth_identity, "~> 0.3"},
      {:guardian, "~> 2.1"},
      {:bcrypt_elixir, "~> 2.0"},

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
      {:credo_naming, "~> 1.0", only: [:dev, :test], runtime: false},

      # Security check
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: true},
      {:mix_audit, "~> 1.0", only: [:dev, :test], runtime: false},

      # Email
      {:bamboo, "~> 2.1.0"},
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
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
