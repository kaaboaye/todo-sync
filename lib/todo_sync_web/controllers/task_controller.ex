defmodule TodoSyncWeb.TaskController do
  use TodoSyncWeb, :controller

  alias TodoSync.Tasks
  alias TodoSync.Tasks.TodoTask

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

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task!(id)

    with {:ok, %TodoTask{} = task} <- Tasks.update_task(task, task_params) do
      render(conn, "show.json", task: task)
    end
  end
end
