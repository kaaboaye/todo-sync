defmodule TodoSyncWeb.TaskController do
  use TodoSyncWeb, :controller

  alias TodoSync.Tasks

  action_fallback TodoSyncWeb.FallbackController

  def sync(conn, _params) do
    with {:ok, sync_result} <- Tasks.sync() do
      render(conn, "sync_result.json", result: sync_result)
    end
  end

  def search(conn, params) do
    tasks = Tasks.search_tasks(params)
    render(conn, "index.json", tasks: tasks)
  end

  def update(conn, params) do
    task_id = Map.fetch!(params, "id")

    with %{} = task_params <- params["task"] || {:error, :bad_request},
         %{} = task <- Tasks.get_task(task_id) || {:error, :not_found},
         {:ok, task} <- Tasks.update_task(task, task_params) do
      render(conn, "show.json", task: task)
    end
  end
end
