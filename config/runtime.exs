import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :my_app, MyApp.Repo,
    # ssl: true,
    socket_options: [:inet6],
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # IMPORTANT: Get the app_name we're using
  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  config :my_app, MyAppWeb.Endpoint,
    url: [host: "#{app_name}.fly.dev", port: 80],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: String.to_integer(System.get_env("PORT") || "4000")
    ],
    secret_key_base: secret_key_base

  config :my_app, MyAppWeb.Authentication,
    issuer: "my_app",
    secret_key: {:system, "GUARIAN_SECRET_KEY"}

  config :my_app, MyApp.Mailer,
    adapter: Bamboo.SendGridAdapter,
    api_key: {:system, "SENDGRID_KEY"}

  config :honeybadger,
    api_key: {:system, "HONEYBADGER_API_KEY"},
    environment_name: :staging,
    revision: {:system, "HEROKU_SLUG_COMMIT"}

  config :my_app, MyAppWeb.Router,
    session_key: {:system, "SESSION_KEY"},
    session_signing_salt: {:system, "SESSION_SIGNING_SALT"}

  plausible_host = System.get_env("PLAUSIBLE_HOST")

  config :my_app, :plausible_tracking,
    host: plausible_host,
    script: "#{plausible_host}/js/plausible.js",
    enabled: false,
    api_token: System.get_env("PLAUSIBLE_API_TOKEN")

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  config :my_app, MyAppWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
