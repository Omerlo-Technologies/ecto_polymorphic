defmodule EctoPolymorphic.Article do
  use Ecto.Schema

  import Ecto.Changeset
  import EctoPolymorphic

  schema "article" do
    field :visual, EctoPolymorphic,
      types: [
        image: EctoPolymorphic.Image,
        slideshow: EctoPolymorphic.Slideshow,
        video: EctoPolymorphic.Video
      ],
      type_field: :type
  end

  def changeset(struct_or_changeset, attrs \\ %{}) do
    struct_or_changeset
    |> cast(attrs, [])
    |> cast_polymorphic(:visual)
  end
end
