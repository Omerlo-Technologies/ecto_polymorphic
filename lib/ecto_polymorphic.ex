defmodule EctoPolymorphic do
  use Ecto.ParameterizedType

  import Ecto.Changeset

  def type(_params), do: :map

  def init(opts) do
    types =
      opts
      |> Keyword.get(:types, [])
      |> Map.new(fn {type, schema} -> {Atom.to_string(type), schema} end)

    %{
      default: Keyword.get(opts, :default, nil),
      # on_replace: Keyword.fetch!(opts, :on_replace),
      # on_type_not_found: Keyword.get(opts, :on_type_not_found, :changeset_error),
      type_field: Keyword.get(opts, :type_field, :__type__),
      types: types
    }
  end

  def cast(_data, _params) do
    raise "DO NOT USE THIS ONE, use cast_polymorphic/2 instead"
  end

  def load(_data, _loader, _params) do
    {:ok, nil}
  end

  def dump(_data, _dumper, _params) do
    {:ok, nil}
  end

  def equal?(a, b, _params) do
    a == b
  end

  @doc """

  ## Examples

      iex> cast_polymorphic(changeset, :visual, required: false)
      %Ecto.Changeset{}

      iex> cast_polymorphic(changeset, :visual, with: &custom_changeset/2)
      %Ecto.Changeset{}

  """
  def cast_polymorphic(%Ecto.Changeset{} = parent_changeset, field, opts \\ []) do
    # TODO supports array
    params = Map.get(parent_changeset.params || %{}, Atom.to_string(field), %{})
    params = Map.new(params, fn {k, v} -> {to_string(k), v} end)

    parent_changeset =
      Map.update!(parent_changeset, :params, &Map.put(&1, to_string(field), params))

    if polymorphic_changeset = get_polymorphic_field(parent_changeset, field) do
      changeset_fun = Keyword.get(opts, :with, &polymorphic_changeset.data.__struct__.changeset/2)
      do_cast_polymorphic(parent_changeset, polymorphic_changeset, changeset_fun, field)
    else
      field_opts = get_field_options(parent_changeset.data.__struct__, field)

      changeset =
        {%{}, %{type: :string}}
        |> change()
        |> add_error(field_opts.type_field, "missing type")

      put_change(parent_changeset, field, changeset)
    end
  end

  defp do_cast_polymorphic(parent_changeset, changeset, changeset_fun, field) do
    params = Map.get(parent_changeset.params, to_string(field))
    changeset = changeset_fun.(changeset, params)
    origin_visual_struct = Map.get(parent_changeset.data.visual || %{}, :__struct__)

    cond do
      !Enum.empty?(changeset.changes) ->
        put_change(parent_changeset, field, changeset)

      origin_visual_struct != changeset.data.__struct__ ->
        put_change(parent_changeset, field, changeset)

      true ->
        parent_changeset
    end
  end

  defp get_polymorphic_field(changeset, field) do
    opts = get_field_options(changeset.data.__struct__, field)
    type = changeset.params[to_string(field)][to_string(opts.type_field)]
    module = Map.get(opts.types, type)

    struct_or_changeset = changeset |> get_field(field) |> do_get_polymorphic_field(module)

    if struct_or_changeset do
      change(struct_or_changeset)
    end
  end

  defp do_get_polymorphic_field(nil, nil), do: nil
  defp do_get_polymorphic_field(struct_or_changeset, nil), do: struct_or_changeset
  defp do_get_polymorphic_field(nil, module), do: struct(module)

  defp do_get_polymorphic_field(struct_or_changeset, module) do
    case struct_or_changeset do
      %Ecto.Changeset{data: %{__struct__: ^module}} -> struct_or_changeset
      %{__struct__: ^module} -> struct_or_changeset
      _ -> struct(module)
    end
  end

  defp get_field_options(schema, field) do
    try do
      schema.__schema__(:type, field)
    rescue
      _ in UndefinedFunctionError ->
        raise ArgumentError, "#{inspect(schema)} is not an Ecto schema"
    else
      {:parameterized, __MODULE__, options} -> Map.put(options, :array?, false)
      {:array, {:parameterized, __MODULE__, options}} -> Map.put(options, :array?, true)
      # Dunno when it could happen
      # {_, {:parameterized, __MODULE__, options}} -> Map.put(options, :array?, false)
      nil -> raise ArgumentError, "#{field} is not a visual"
    end
  end
end
