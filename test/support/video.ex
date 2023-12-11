defmodule EctoPolymorphic.Video do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :url, :string
    field :provider, Ecto.Enum, values: ~w[youtube dailymotion]a
  end

  def changeset(struct_or_changeset, attrs \\ %{}) do
    struct_or_changeset
    |> cast(attrs, [:url, :provider])
    |> validate_required([:url, :provider])
  end
end
