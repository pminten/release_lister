defmodule ReleaseLister.Templates do
  require EEx
  
  templates = [
    index_template: [:descriptions, :releases],
  ]

  # Number of lines of the release body to always show
  @summary_lines 5

  defp first_lines(s) do
    String.split(s, "\n") |> Stream.take(@summary_lines) |> Enum.join("\n")
  end

  defp rest_lines(s) do
    String.split(s, "\n") |> Stream.drop(@summary_lines) |> Enum.join("\n")
  end

  # Format an ISO timestamp string as returned by GitHub.
  defp format_timestamp(ts) do
    String.replace(ts, %r/[A-Z]/, " ")
  end

  # HTML escape function from ex_doc
  defp h(binary) do
    escape_map = [{ %r(&), "\\&amp;" }, { %r(<), "\\&lt;" }, { %r(>), "\\&gt;" }, { %r("), "\\&quot;" }]
    Enum.reduce escape_map, binary, fn({ re, escape }, acc) -> Regex.replace(re, acc, escape) end
  end

  Enum.each templates, fn({ name, args }) ->
    filename = Path.expand("templates/#{name}.eex", __DIR__)
    EEx.function_from_file :def, name, filename, args
  end
end
