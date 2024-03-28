defmodule OzWeb.PageParam do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :page, :integer, default: 1
    field :page_size, :integer, default: 10
  end

  @doc false
  def changeset(entity, attrs) do
    entity
    |> cast(attrs, __schema__(:fields))
    |> validate_required(__schema__(:fields))
    |> validate_number(:page, greater_than: 0)
    |> validate_number(:page_size, greater_than: 0)
  end

  def cast_and_validate(attrs) do
    cast_and_validate(%__MODULE__{}, attrs)
  end

  def cast_and_validate(entity, attrs) do
    entity
    |> changeset(attrs)
    |> apply_action(:insert)
    # |> to_map()
  end

  # def to_map({:ok, struct}), do: {:ok, Map.from_struct(struct)}

  # def to_map(payload), do: payload
end
