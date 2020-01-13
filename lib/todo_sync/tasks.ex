defmodule TodoSync.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false

  alias TodoSync.Repo

  alias TodoSync.Tasks.Todoist
  alias TodoSync.Tasks.TodoTask
  alias TodoSync.Tasks.Mock

  defp conf, do: Application.get_env(:todo_sync, __MODULE__, [])
  defp mock_remote, do: Keyword.get(conf(), :mock_remote, false)

  defp todoist_provider, do: unless(mock_remote(), do: Todoist, else: Mock)
  # defp remember_the_milk_provider, do: unless(mock_remote(), do: RememberTheMilk, else: Mock)

  @doc """
  Searches and returns list of tasks.

  As `params` it accepts `Enumerable` of key-value pairs.
  Allowed keys:
    - `"name"` - Performs ILIKE search for tasks having given name
    - `"source"` - Filters out different sources then provided.
      Allowed sources: `"todoist"`, `"remember_the_milk"`.
  """
  @spec search_tasks(%{binary => term}) :: [%TodoTask{}]
  def search_tasks(params) do
    Enum.reduce(params, TodoTask, fn
      {"name", name}, query -> where(query, [task], ilike(task.name, ^"%#{name}%"))
      {"source", source}, query -> where(query, [task], task.source == ^source)
      _, query -> query
    end)
    |> Repo.all()
  end

  @doc """
  Synchronizes local tasks with sources.
  """
  @spec sync ::
          {:ok, %{created: non_neg_integer, deleted: non_neg_integer, updated: non_neg_integer}}
          | {:error, any}
  # explained when used
  @max_postgres_insert_all_tasks Integer.floor_div(65535, 4)
  def sync do
    # This implementation is focused on bringing number of database requests to the minimum
    #   because it's usually the most costly part of processes like that.

    # Algorithm:
    # - Fetch all remote tasks
    # - Remove tasks which has been deleted remotely
    # - Fetch all tasks from local database
    # - Create in memory index allowing to quickly check whether remote task
    #     is already in local store
    # - Determine which remote tasks are to be inserted or updated
    # - Perform batch inserts
    # - Perform updates

    # Possible improvements:
    # - Use lock for update or other semaphore in order to eliminate race conditions
    # - Perform updates via batch upsets but in order to get a number of inserted and updated rows
    #     usage of such query https://stackoverflow.com/a/38858662/8651854 would be required
    #     and Ecto does not supports such queries.
    # - Use `Repo.stream` and`Stream` instead of `Repo.all` and `Enum` but until all of the data
    #     fits into the memory there is no need of doing that.

    todoist_tasks = todoist_provider().fetch_tasks()
    todoist_remote_ids = Enum.map(todoist_tasks, & &1.remote_id)

    remote_tasks = todoist_tasks
    # Changes required to sync data from multiple sources are commented out below
    # remote_tasks = todoist_tasks ++ remember_the_milk_tasks

    # begin transaction
    fn ->
      delete_query =
        from task in TodoTask,
          where: task.source == "todoist" and task.remote_id not in ^todoist_remote_ids

      # remember_the_milk_tasks = RememberTheMilk.fetch_tasks()
      # remember_the_milk_remote_ids = Enum.map(remember_the_milk_tasks, & &1.remote_id)

      # delete_query =
      #   from task in TodoTask,
      #     or_where: task.source == "todoist" and task.remote_id not in ^todoist_remote_ids,
      #     or_where: task.source == "remember_the_milk" and task.remote_id not in ^todoist_remote_ids

      {deleted_count, nil} = Repo.delete_all(delete_query)

      repo_tasks = Repo.all(TodoTask)

      # the code below creates map which enables constant time, in memory lookups for [source, remote_id]
      # eg. map %{
      #    todoist: %{
      #       "123" => %TodoTask{…},
      #       "456" => %TodoTask{…},
      #    },
      #    some_other_todo: %{
      #       "BAC61998-E51D-41AE-B897-F3FC3AA1B32C" => %TodoTask{…},
      #       "2E71751E-82B1-4C8E-989C-E422DFD6F924" => %TodoTask{…},
      #    },
      # }

      repo_provider_ids =
        repo_tasks
        |> Enum.group_by(& &1.source, &{&1.remote_id, &1})
        |> Map.new(fn {k, v} -> {k, Map.new(v)} end)

      # check which tasks are already in the database
      {to_insert, to_update} =
        Enum.reduce(remote_tasks, {[], []}, fn remote_task, {to_insert, to_update} ->
          if repo_task = get_in(repo_provider_ids, [remote_task.source, remote_task.remote_id]),
            do: {to_insert, [{repo_task, remote_task} | to_update]},
            else: {[remote_task | to_insert], to_update}
        end)

      # when using insert_all and PostgreSQL its important to remember to never exceed
      # 65535 parameters in single INSERT query because it is a maximum number of
      # supported parameters in single query
      to_insert
      |> Enum.chunk_every(@max_postgres_insert_all_tasks)
      |> Enum.each(&Repo.insert_all(TodoTask, &1))

      updated_count =
        to_update
        |> Enum.count(fn {repo_task, remote_task} ->
          changeset = TodoTask.changeset(repo_task, remote_task)

          # normally `if changes` wouldn't be necessary but since we want to know
          # a number of updates this lambda needs to return truthy value on update
          # and falsy on noop
          if Enum.count(changeset.changes) > 0,
            do: Repo.update!(changeset)
        end)

      %{
        deleted: deleted_count,
        created: length(to_insert),
        updated: updated_count
      }
    end
    |> Repo.transaction()
  end

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%TodoTask{}, ...]

  """
  def list_tasks do
    Repo.all(TodoTask)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %TodoTask{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(TodoTask, id)

  @doc """
  Gets a single task.

  Return `nil` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %TodoTask{}

      iex> get_task!(456)
      nil

  """
  def get_task(id), do: Repo.get(TodoTask, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %TodoTask{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %TodoTask{}
    |> TodoTask.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %TodoTask{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%TodoTask{} = task, attrs) do
    fn ->
      task_update_result =
        task
        |> TodoTask.update_changeset(attrs)
        |> Repo.update()

      with {:ok, task} <- task_update_result do
        :ok = provider_from_source(task.source).update_task(task)

        task
      else
        {:error, err} -> Repo.rollback(err)
      end
    end
    |> Repo.transaction()
  end

  @doc """
  Deletes a Task.

  ## Examples

      iex> delete_task(task)
      {:ok, %TodoTask{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%TodoTask{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{source: %TodoTask{}}

  """
  def change_task(%TodoTask{} = task) do
    TodoTask.changeset(task, %{})
  end

  defp provider_from_source(:todoist), do: todoist_provider()
  defp provider_from_source(:remember_the_milk), do: throw("not implemented")
end
