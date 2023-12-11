defmodule EctoPolymorphic.Slideshow do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    embeds_many :images, EctoPolymorphic.Image
  end

  def changeset(struct_or_changeset, attrs \\ %{}) do
    struct_or_changeset
    |> cast(attrs, [])
    |> cast_embed(:images)
  end
end
