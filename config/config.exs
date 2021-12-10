# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :boilerplate,
  ecto_repos: [Boilerplate.Repo]

# Configures the endpoint
config :boilerplate, BoilerplateWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BoilerplateWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Boilerplate.PubSub,
  live_view: [signing_salt: "VhGdDVAr"]

config :boilerplate, Nioomi.Repo, migration_primary_key: [type: :uuid]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :boilerplate, Boilerplate.Mailer, adapter: Bamboo.LocalAdapter

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.ts --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :geo_postgis, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
