defmodule TodoSyncWeb.Router do
  use TodoSyncWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TodoSyncWeb do
    pipe_through :api

    post "/sync", TaskController, :sync

    scope "/tasks" do
      get "/search", TaskController, :search
    end
  end
end
