defmodule Mix.Tasks.Day2 do
  use Mix.Task
  import InputUtils

  @red_limit 12
  @green_limit 13
  @blue_limit 14

  @input_path "input.txt"

  defp is_game_possible?(shown_cubes) do
    Enum.all?(
      [
        {"red", @red_limit},
        {"green", @green_limit},
        {"blue", @blue_limit}
      ],
      fn {color, limit} ->
        Map.get(shown_cubes, color, 0) <= limit
      end
    )
  end

  defp parse_game_id(tokens) do
    tokens
    |> Enum.at(0)
    |> String.split(" ")
    |> Enum.at(1)
    |> String.to_integer()
  end

  defp line_into_map(line) do
    line
    |> String.split(", ")
    |> Enum.reduce(%{"red" => 0, "green" => 0, "blue" => 0}, fn token, map ->
      [value, key] = String.split(token, " ")
      count = String.to_integer(value)
      Map.update(map, key, count, fn old_count -> old_count + count end)
    end)
  end

  defp inspect_shown_cubes(game_log) do
    tokens = String.split(game_log, ": ")
    game_id = parse_game_id(tokens)
    cube_reveals = String.split(Enum.at(tokens, 1), "; ")

    is_valid_game =
      cube_reveals
      |> Enum.map(fn line -> line_into_map(line) end)
      |> Enum.all?(fn cube_counts -> is_game_possible?(cube_counts) end)

    {game_id, is_valid_game}
  end

  defp count_max_cubes(game_log) do
    tokens = String.split(game_log, ": ")
    cube_reveals = String.split(Enum.at(tokens, 1), "; ")

    cube_reveals
    |> Enum.map(fn line -> line_into_map(line) end)
    |> Enum.reduce(%{"red" => 0, "green" => 0, "blue" => 0}, fn count, max_counts ->
      ["red", "green", "blue"]
      |> Enum.reduce(max_counts, fn key, max_inner ->
        if Map.get(count, key) > Map.get(max_inner, key) do
          Map.put(max_inner, key, Map.get(count, key))
        else
          max_inner
        end
      end)
    end)
  end

  defp part_one(input) do
    input
    |> Enum.reduce(0, fn game_log, sum ->
      {game_id, is_game_valid} = inspect_shown_cubes(game_log)
      sum + if is_game_valid, do: game_id, else: 0
    end)
  end

  defp part_two(input) do
    input
    |> Enum.reduce(0, fn game_log, sum ->
      max_cubes = count_max_cubes(game_log)
      sum + Map.get(max_cubes, "red") * Map.get(max_cubes, "green") * Map.get(max_cubes, "blue")
    end)
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    IO.puts("Part one: #{part_one(input)}.")
    IO.puts("Part two: #{part_two(input)}.")
  end
end
