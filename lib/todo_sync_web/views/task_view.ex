defmodule TodoSyncWeb.TaskView do
  use TodoSyncWeb, :view
  alias TodoSyncWeb.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{id: task.id,
      name: task.name,
      source: task.source,
      remote_id: task.remote_id}
  end
end
