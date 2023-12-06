defmodule InputUtils do
  def read_input_into_lines(cwd, path, line_separator \\ "\n") do
    cwd
    |> Path.dirname()
    |> Path.join(path)
    |> File.read!()
    |> String.trim_trailing("\n")
    |> String.split(line_separator)
  end
end
