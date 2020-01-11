defmodule TodoSync.Tasks.Provider do
  alias TodoSync.Tasks.Task
  alias TodoSync.Tasks.TaskSource

  @callback fetch_tasks :: [%{name: binary, remote_id: binary, source: TaskSource.t()}]
  @callback update_task(Task.t(), %{name: binary}) :: {:ok, Task.t()} | {:error, any}
end
