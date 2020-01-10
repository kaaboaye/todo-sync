defmodule TodoSync.TasksTest do
  use TodoSync.DataCase

  alias TodoSync.Tasks

  describe "tasks" do
    alias TodoSync.Tasks.Task

    @valid_attrs %{
      name: "some name",
      remote_id: "some remote_id",
      source: :todoist
    }

    @update_attrs %{
      name: "some updated name",
      remote_id: "some updated remote_id",
      source: "remember_the_milk"
    }

    @invalid_attrs %{
      name: nil,
      remote_id: nil,
      source: nil
    }

    def task_fixture(attrs \\ %{}) do
      {:ok, task} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tasks.create_task()

      task
    end

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Tasks.create_task(@valid_attrs)
      assert task.name == "some name"
      assert task.remote_id == "some remote_id"
      assert task.source == :todoist
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Tasks.update_task(task, @update_attrs)
      assert task.name == "some updated name"
      assert task.remote_id == "some updated remote_id"
      assert task.source == :remember_the_milk
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
