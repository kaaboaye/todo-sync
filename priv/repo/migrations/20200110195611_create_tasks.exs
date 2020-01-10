defmodule TodoSync.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :name, :text, null: false
      add :source, :task_source, null: false
      add :remote_id, :text, null: false
    end

    create unique_index(:tasks, [:source, :remote_id])
  end
end
