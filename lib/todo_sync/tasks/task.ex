defmodule TodoSync.Tasks.TodoTask do
  @type t :: %__MODULE__{}

  use Ecto.Schema

  import Ecto.Changeset

  alias TodoSync.Tasks.TaskSource

  schema "tasks" do
    field :name, :string
    field :source, TaskSource
    field :remote_id, :string
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:name, :source, :remote_id])
    |> unique_constraint(:remote_id, name: "tasks_source_remote_id_index")
    |> validate_required([:name, :source, :remote_id])
  end
end
