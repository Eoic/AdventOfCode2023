defmodule InputUtils do
  def read_input_into_lines(cwd, path) do
    cwd
    |> Path.dirname()
    |> Path.join(path)
    |> File.read!()
    |> String.trim_trailing("\n")
    |> String.split("\n")
  end
end
