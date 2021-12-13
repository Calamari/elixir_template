import Config

# Configure your database
config :my_app, MyApp.Repo,
  username: "postgres",
  password: "postgres",
  database: "my_app_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :my_app, MyAppWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "CNI5bEYwsu1MxxxZOH4kfoCf6LKY6CtywOcsMRZAwkSWryKNyEEyQgw+70kHw5KS",
  watchers: [
    node: [
      "build.js",
      cd: Path.expand("../assets/scripts/", __DIR__),
      env: %{"ESBUILD_LOG_LEVEL" => "silent", "ESBUILD_WATCH" => "1", "NODE_ENV" => "development"}
    ]
  ]

config :my_app, MyAppWeb.Authentication,
  issuer: "my_app",
  secret_key: "qs0y6iXwd36NdnKpD3aZoMlY9qJCq0bq8gsla2QynK1BtyIa9udlcJ0W1RJ3n3jX"

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :my_app, MyAppWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/my_app_web/(live|views)/.*(ex)$",
      ~r"lib/my_app_web/templates/.*(eex)$"
    ]
  ]

config :my_app, MyAppWeb.Router,
  session_key: "my_app_dev_sess",
  session_signing_salt: "bzt+fviYAyUARQr1KzfxxWtv41fsqcAiQKqlIPVvc4kFeAlByE+NBb+aIf3K2DAh"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
