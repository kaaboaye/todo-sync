defmodule TodoSync.Tasks.Todoist do
  use Tesla

  alias TodoSync.Tasks.Provider

  @behaviour Provider

  defp conf, do: Application.get_env(:todo_sync, __MODULE__, [])
  defp api_token, do: Keyword.fetch!(conf(), :api_token)

  plug Tesla.Middleware.BaseUrl, "https://api.todoist.com"
  plug Tesla.Middleware.Headers, [{"authorization", "Bearer " <> api_token()}]
  plug Tesla.Middleware.JSON

  plug Tesla.Middleware.Retry,
    should_retry: fn
      {:ok, %{status: 500}} -> true
      {:ok, _} -> false
      {:error, _} -> true
    end

  plug Tesla.Middleware.Logger

  @impl Provider
  def fetch_tasks do
    res = %{status: 200} = get!("/rest/v1/tasks")

    Enum.map(
      res.body,
      &%{
        name: Map.fetch!(&1, "content"),
        remote_id: Map.fetch!(&1, "id") |> to_string(),
        source: :todoist
      }
    )
  end

  @impl Provider
  def update_task(%{source: :todoist, remote_id: remote_id, name: name}) do
    %{status: 204} = post!("/rest/v1/tasks/#{remote_id}", %{"content" => name})
    :ok
  end
end
