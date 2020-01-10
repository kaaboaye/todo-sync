defmodule TodoSync.Repo.Migrations.CreateTaskSource do
  use Ecto.Migration

  alias TodoSync.Tasks.TaskSource

  def up do
    TaskSource.create_type()
  end

  def down do
    TaskSource.drop_type()
  end
end
