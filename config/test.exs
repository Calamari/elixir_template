import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :my_app, MyApp.Repo,
  username: "postgres",
  password: "postgres",
  database: "my_app_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :my_app, MyAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "AYdzMYgtlMSGv8FKH9O2gAw9i8FCCAeci7aDYbuRu7coPFqRNzDIawqByLFGi51t",
  server: false

config :my_app, MyAppWeb.Router,
  session_key: "my_app_dev_sess",
  session_signing_salt: "mz3z6MRz16uGDEvsUhlG/i3cFhI627+lFKki1Nzhlh/IiCkhR0EAMgZQfrfp2Lxn"

config :my_app, MyAppWeb.Authentication,
  issuer: "my_app",
  secret_key: "qs0y6iXwd36NdnKpD3aZoMlY9qJCq0bq8gsla2QynK1BtyIa9udlcJ0W1RJ3n3jX"

# In test we don't send emails.
config :my_app, MyApp.Mailer, adapter: Bamboo.TestAdapter

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
