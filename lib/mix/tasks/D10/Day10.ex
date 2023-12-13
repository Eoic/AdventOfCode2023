defmodule Mix.Tasks.Day10 do
  use Mix.Task
  import InputUtils

  @input_path "input_sample.txt"

  @inverse_connector %{
    :left => :right,
    :right => :left,
    :top => :bottom,
    :bottom => :top
  }

  @direction_to_delta %{
    :left => [-1, 0],
    :top => [0, -1],
    :right => [1, 0],
    :bottom => [0, 1]
  }

  def get_cell_connectors(cell) do
    case cell do
      "|" -> [:top, :bottom]
      "-" -> [:left, :right]
      "L" -> [:top, :right]
      "J" -> [:top, :left]
      "7" -> [:bottom, :left]
      "F" -> [:bottom, :right]
      "." -> [:nothing]
      "S" -> :start
    end
  end

  def parse_map(input) do
    width =
      input
      |> Enum.at(0)
      |> String.graphemes()
      |> length()

    height = length(input)

    input
    |> Enum.with_index()
    |> Enum.reduce(%{:width => width, :height => height}, fn {row, y}, map_outer ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(map_outer, fn {cell, x}, map_inner ->
        directions = get_cell_connectors(cell)

        map_inner
        |> Map.put([x, y], directions)
        |> then(fn map -> if directions == :start, do: Map.put(map, :start, [x, y]), else: map end)
      end)
    end)
  end

  def can_go_to?(map, [current_x, current_y], direction_to) do
    [x, y] = Map.get(@direction_to_delta, direction_to)
    [new_x, new_y] = [x + current_x, y + current_y]

    if new_x >= Map.get(map, :width) or new_y >= Map.get(map, :height) or new_x < 0 or new_y < 0 do
      false
    else
      cond do
        Enum.member?(Map.get(map, [new_x, new_y]), Map.get(@inverse_connector, direction_to)) -> true
        true -> false
      end
    end
  end

  def traverse_map(map) do
    start_position = Map.get(map, :start)
  end

  def part_one(map) do
    IO.inspect(["Starting position at", Map.get(map, :start)])
    IO.puts("Can go: #{can_go_to?(map, [1, 1], :left)}.")
    :noop
  end

  def part_two(_input) do
    :noop
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    map = parse_map(input)
    IO.puts("Part one: #{part_one(map)}.")
    IO.puts("Part two: #{part_two(map)}.")
  end
end
