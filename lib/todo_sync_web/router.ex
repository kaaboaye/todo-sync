defmodule TodoSyncWeb.Router do
  use TodoSyncWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TodoSyncWeb do
    pipe_through :api

    resources "/tasks", TaskController
  end
end
