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

  def resolve_location_reverse(location, map_ranges) do
    map_ranges
    |> Enum.find_value(nil, fn range ->
      cond do
        # D - S - L, e.g. 52 - 50 - 57 (57 -> 55)
        # Check whether the computed value exists in the next (upper) map (in any of its ranges).
        # If not we missed the range and should try with next location.
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
    # TODO:
    # Find minimum location and start resolving maps in reverse.
    # First successful reverse resolution of all maps means lowest location.
    # Start from location 0 and increase until resolved to valid seed (meaning, result is in seed range)
    :noop
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path, "\n\n")
    data = parse_maps(input)
    IO.puts("Part one: #{part_one(data)}.")
    IO.puts("Part two: #{part_two(data)}.")
  end
end
