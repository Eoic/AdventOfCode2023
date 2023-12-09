defmodule Mix.Tasks.Day6 do
  use Mix.Task
  import InputUtils

  @input_path "input.txt"

  def parse_races(input) do
    input
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> tl()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
  end

  def parse_long_races(input) do
    input
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> tl()
      |> Enum.join("")
      |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  def find_wins_count({time, record_distance}) do
    1..(time - 1)
    |> Enum.filter(&((time - &1) * &1 > record_distance))
    |> Enum.count()
  end

  def part_one(races) do
    races
    |> Enum.map(&find_wins_count/1)
    |> Enum.product()
  end

  def part_two(races) do
    find_wins_count(races)
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    races = parse_races(input)
    long_races = parse_long_races(input)
    IO.puts("Part one: #{part_one(races)}.")
    IO.puts("Part two: #{part_two(long_races)}.")
  end
end
