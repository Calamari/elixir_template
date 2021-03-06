# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :my_app,
  ecto_repos: [MyApp.Repo]

# Configures the endpoint
config :my_app, MyAppWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MyApp.PubSub,
  live_view: [signing_salt: "VhGdDVAr"]

config :my_app, MyApp.Repo, migration_primary_key: [type: :uuid]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :my_app, MyApp.Mailer, adapter: Bamboo.LocalAdapter
config :my_app, :email_sender, "joda@example.com"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    "build.js",
    cd: Path.expand("../assets/scripts", __DIR__),
    env: %{
      "ESBUILD_LOG_LEVEL" => "silent",
      "ESBUILD_WATCH" => "1",
      "NODE_ENV" => "development",
      "NODE_PATH" => Path.expand("../deps", __DIR__)
    }
  ]

config :ueberauth, Ueberauth,
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [
         param_nesting: "account",
         request_path: "/register",
         callback_path: "/register",
         callback_methods: ["POST"]
       ]}
  ]

config :my_app, MyAppWeb.Authentication, issuer: "my_app"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :geo_postgis, json_library: Jason

plausible_host = System.get_env("PLAUSIBLE_HOST")

config :my_app, :plausible_tracking,
  host: plausible_host,
  script: "#{plausible_host}/js/plausible.js",
  enabled: false,
  api_token: System.get_env("PLAUSIBLE_DEV_API_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
