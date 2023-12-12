# Used by "mix format"
locals_without_parens = [
  polymorphic_one: 2
]

[
  import_deps: [:ecto],
  locals_without_parens: locals_without_parens,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  export: [locals_without_parens: locals_without_parens]
]
