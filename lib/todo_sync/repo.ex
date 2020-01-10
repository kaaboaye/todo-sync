defmodule TodoSync.Repo do
  use Ecto.Repo,
    otp_app: :todo_sync,
    adapter: Ecto.Adapters.Postgres
end
