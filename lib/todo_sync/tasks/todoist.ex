defmodule TodoSync.Tasks.Todoist do
  use Tesla

  alias TodoSync.Tasks.Provider

  @behaviour Provider

  plug Tesla.Middleware.BaseUrl, "https://api.todoist.com"

  plug Tesla.Middleware.Headers, [
    {"authorization", "Bearer 03f799bf70d7ceabc88ea4075c154721cc12305b"}
  ]

  plug Tesla.Middleware.JSON

  @impl Provider
  def fetch_tasks do
    res = get!("/rest/v1/tasks")
    %{status: 200} = res

    Enum.map(res.body, &task_from_todoist/1)
  end

  defp task_from_todoist(task) do
    %{
      name: Map.fetch!(task, "content"),
      remote_id: Map.fetch!(task, "id") |> to_string(),
      source: :todoist
    }
  end
end
