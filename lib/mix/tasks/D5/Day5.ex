defmodule Mix.Tasks.Day5 do
  use Mix.Task
  import InputUtils

  @input_path "input.txt"

  defmodule SeedRange do
    defstruct [:source, :destination, :length]
  end

  def input_to_ranges(input) do
    lines = String.split(input, "\n", trim: true)

    tl(lines)
    |> Enum.map(fn line ->
      [destination, source, offset] = String.split(line, " ", trim: true) |> Enum.map(&String.to_integer/1)
      %{destination: destination, source: source, offset: offset}
    end)
  end

  def parse_maps(input) do
    seeds =
      input
      |> hd()
      |> String.split(": ")
      |> Enum.at(1)
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    almanac =
      input
      |> tl
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {section, index}, almanac_acc ->
        ranges = input_to_ranges(section)
        Map.put(almanac_acc, index, ranges)
      end)

    [seeds, almanac]
  end

  def resolve_location(seed, map_ranges) do
    map_ranges
    |> Enum.find_value(seed, fn range ->
      cond do
        range.source > seed ->
          false

        range.source + range.offset >= seed ->
          to_add = seed - range.source
          range.destination + to_add

        true ->
          false
      end
    end)
  end

  defp part_one([seeds, almanac]) do
    seeds
    |> Enum.map(fn seed ->
      Enum.reduce(0..6, seed, fn index, location ->
        resolve_location(location, Map.get(almanac, index))
      end)
    end)
    |> Enum.min()
  end

  defp part_two([seeds, almanac]) do
    seed_ranges = Enum.chunk_every(seeds, 2, 2)

    IO.inspect(seed_ranges, charlists: :as_lists)

    :noop
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path, "\n\n")
    data = parse_maps(input)
    IO.puts("Part one: #{part_one(data)}.")
    IO.puts("Part two: #{part_two(data)}.")
  end
end
