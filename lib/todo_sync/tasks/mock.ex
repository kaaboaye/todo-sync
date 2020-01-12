defmodule TodoSync.Tasks.Mock do
  alias TodoSync.Tasks.Provider

  @behaviour Provider

  @impl Provider
  def fetch_tasks do
    []
  end

  @impl Provider
  def update_task(_) do
    :ok
  end
end
