defmodule EctoPolymorphicTest do
  use EctoPolymorphic.DataCase

  import Ecto.Changeset

  alias EctoPolymorphic.Article
  alias EctoPolymorphic.Image
  alias EctoPolymorphic.Video
  alias EctoPolymorphic.Slideshow

  describe "cast the right type" do
    test "with type specified but nil changeset" do
      changeset = Article.changeset(%Article{}, %{visual: %{type: "image"}})

      # assert visual_changeset = get_change(changeset, :visual)
      # assert visual_changeset.data.__struct__ == Image
    end

    test "change type for existing data" do
      visual = Enum.random([Image, Video, Slideshow]) |> struct(%{id: Ecto.UUID.generate()})
      changeset = Article.changeset(%Article{visual: visual}, %{visual: %{type: "image"}})

      visual_changeset = get_field(changeset, :visual)
      assert visual_changeset.data.__struct__ == Image
    end

    test "without type but a changeset" do
      changeset =
        Article.changeset(%Article{visual: %Image{}}, %{visual: %{file_key: "titi.jpg"}})

      assert visual_changeset = get_change(changeset, :visual)
      assert visual_changeset.data.__struct__ == Image
    end

    test "without type and nil changeset" do
      changeset = Article.changeset(%Article{}, %{})
      visual_changeset = get_field(changeset, :visual)
      refute visual_changeset.valid?
      assert "missing type" in errors_on(visual_changeset).type
    end
  end
end
