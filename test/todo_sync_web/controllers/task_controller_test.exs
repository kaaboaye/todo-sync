defmodule TodoSyncWeb.TaskControllerTest do
  use TodoSyncWeb.ConnCase

  alias TodoSync.Tasks
  alias TodoSync.Tasks.TodoTask

  @create_attrs %{
    name: "some name",
    remote_id: "some remote_id",
    source: "todoist"
  }
  @update_attrs %{
    name: "some updated name",
    remote_id: "some updated remote_id",
    source: "remember_the_milk"
  }
  @invalid_attrs %{name: nil, remote_id: nil, source: nil}

  def fixture(:task) do
    {:ok, task} = Tasks.create_task(@create_attrs)
    task
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "search" do
    test "search tasks", %{conn: conn} do
      task = fixture(:task)

      conn = get(conn, Routes.task_path(conn, :search))
      assert [%{"id" => task_id, "name" => task_name}] = json_response(conn, 200)
      assert task.id == task_id
      assert task.name == task_name
    end

    test "search tasks by name positive", %{conn: conn} do
      task = fixture(:task)

      conn = get(conn, Routes.task_path(conn, :search, name: "some"))
      assert [%{"id" => task_id, "name" => task_name}] = json_response(conn, 200)
      assert task.id == task_id
      assert task.name == task_name
    end

    test "search tasks by name negative", %{conn: conn} do
      fixture(:task)

      conn = get(conn, Routes.task_path(conn, :search, name: "none"))
      assert [] = json_response(conn, 200)
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %TodoTask{id: id} = task} do
      conn = patch(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = patch(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "sync tasks" do
    test "syncs tasks", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :sync))
      assert %{"created" => 0, "deleted" => 0, "updated" => 0} == json_response(conn, 200)
    end
  end

  defp create_task(_) do
    task = fixture(:task)
    {:ok, task: task}
  end
end
