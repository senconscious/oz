defmodule OzWeb.PageParam do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :page, :integer, default: 1
    field :page_size, :integer, default: 10
    field :name, :string
  end

  defp fields do
    __schema__(:fields)
  end

  defp required_fields do
    fields() -- [:name]
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, fields())
    |> validate_required(required_fields())
    |> validate_number(:page, greater_than: 0)
    |> validate_number(:page_size, greater_than: 0)
    |> validate_length(:name, min: 3, max: 10)
  end

  def cast_and_validate(attrs) do
    cast_and_validate(%__MODULE__{}, attrs)
  end

  def cast_and_validate(entity, attrs) do
    entity
    |> changeset(attrs)
    |> apply_action(:insert)
  end
end
