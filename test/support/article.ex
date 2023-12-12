defmodule EctoPolymorphic.Article do
  use Ecto.Schema

  import Ecto.Changeset
  import EctoPolymorphic

  alias EctoPolymorphic.Image
  alias EctoPolymorphic.Slideshow
  alias EctoPolymorphic.Video

  schema "article" do
    polymorphic_one :visual,
      types: [
        image: Image,
        slideshow: Slideshow,
        video: Video
      ],
      type_field: :type
  end

  def changeset(struct_or_changeset, attrs \\ %{}) do
    struct_or_changeset
    |> cast(attrs, [])
    |> cast_polymorphic(:visual, with: [image: &Image.special_changeset/2])
  end
end
