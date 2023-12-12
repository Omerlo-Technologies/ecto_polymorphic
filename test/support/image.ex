defmodule EctoPolymorphic.Image do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :file_key, :string
  end

  def special_changeset(struct_or_changeset, attrs \\ %{}) do
    struct_or_changeset
    |> cast(attrs, [:file_key])
    |> validate_required([:file_key])
  end
end
