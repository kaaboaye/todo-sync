defmodule TodoSyncWeb.TaskView do
  use TodoSyncWeb, :view
  alias TodoSyncWeb.TaskView

  def render("index.json", %{tasks: tasks}) do
    render_many(tasks, TaskView, "task.json")
  end

  def render("show.json", %{task: task}) do
    render_one(task, TaskView, "task.json")
  end

  def render("task.json", %{task: task}) do
    %{id: task.id, name: task.name, source: task.source, remote_id: task.remote_id}
  end

  def render("sync_result.json", %{result: result}) do
    %{
      created: result.created,
      updated: result.updated,
      deleted: result.deleted
    }
  end
end
