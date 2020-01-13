import Config

config :todo_sync,
  ecto_repos: [TodoSync.Repo]

# Configures the endpoint
config :todo_sync, TodoSyncWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WeiP+kAeHALJWYSId92VsEIxOrUebboJOWTmBq7gRC+eUDvSsxFyUwgViDG/lDRc",
  render_errors: [view: TodoSyncWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TodoSync.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
