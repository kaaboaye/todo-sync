use Mix.Config

# Configure your database
config :todo_sync, TodoSync.Repo,
  username: "postgres",
  password: "mysecretpassword",
  database: "postgres_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :todo_sync, TodoSyncWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :todo_sync, TodoSync.Tasks, mock_remote: true
