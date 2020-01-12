defmodule TodoSync.Tasks.Provider do
  alias TodoSync.Tasks.Task
  alias TodoSync.Tasks.TaskSource

  @doc """
  Fetches tasks from remote source
  and returns a list of attributes which can be accepted by TodoTask changeset
  """
  @callback fetch_tasks :: [%{name: binary, remote_id: binary, source: TaskSource.t()}]

  @doc """
  Updates task on remote server.
  It takes the assumption that provided task will be accepted by the remote server.
  """
  @callback update_task(Task.t()) :: :ok
end
