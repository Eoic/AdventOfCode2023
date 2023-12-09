defmodule Mix.Tasks.Day8 do
  use Mix.Task
  import InputUtils

  @input_path "input_sample.txt"

  defmodule MapTrace do
    defstruct [
      :directions,
      :directions_length,
      input: ["AAA"],
      initial_input_length: 1,
      is_concurrent: false,
      step_count: 0,
      direction_index: 0
    ]
  end

  defmodule Parallel do
    def map(collection, func) do
      collection
      |> Enum.map(&Task.async(fn -> func.(&1) end))
      |> Enum.map(&Task.await(&1, :infinity))
    end
  end

  def parse_map([directions, nodes]) do
    nodes_processed =
      nodes
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn nodes_row, map ->
        [input, output] = String.split(nodes_row, " = ", trim: true)
        output_nodes = String.replace(output, ["(", ")", ","], "") |> String.split(" ")
        Map.put(map, input, output_nodes)
      end)

    %{
      directions: String.graphemes(directions),
      nodes: nodes_processed
    }
  end

  def direction_to_output_index(directions, direction_index) do
    key = Enum.at(directions, direction_index)
    if key === "L", do: 0, else: 1
  end

  def is_output_reached(map_trace) do
    length(map_trace.input) === map_trace.initial_input_length and
      Enum.all?(map_trace.input, fn token -> String.ends_with?(token, "Z") end)
  end

  def trace_path(map, map_trace) do
    output_index = direction_to_output_index(map_trace.directions, map_trace.direction_index)

    output =
      Parallel.map(map_trace.input, fn input ->
        map
        |> Map.get(:nodes)
        |> Map.get(input)
        |> Enum.at(output_index)
      end)

    map_trace_updated = %{
      map_trace
      | input: output,
        direction_index: rem(map_trace.direction_index + 1, map_trace.directions_length),
        step_count: map_trace.step_count + 1
    }

    if map_trace.is_concurrent do
      if is_output_reached(map_trace_updated) do
        map_trace_updated.step_count
      else
        trace_path(map, map_trace_updated)
      end
    else
      if map_trace.input === ["ZZZ"] do
        map_trace.step_count
      else
        trace_path(map, map_trace_updated)
      end
    end
  end

  def collect_start_nodes(map) do
    map
    |> Map.get(:nodes)
    |> Map.keys()
    |> Enum.filter(&String.ends_with?(&1, "A"))
  end

  def part_one(map) do
    directions = Map.get(map, :directions)

    trace_path(
      map,
      %MapTrace{
        directions: directions,
        directions_length: length(directions)
      }
    )
  end

  def part_two(map) do
    input = collect_start_nodes(map)
    directions = Map.get(map, :directions)

    trace_path(
      map,
      %MapTrace{
        directions: directions,
        directions_length: length(directions),
        input: input,
        initial_input_length: length(input),
        is_concurrent: true
      }
    )
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path, "\n\n")
    map = parse_map(input)
    IO.puts("Part one: #{part_one(map)}.")
    IO.puts("Part two: #{part_two(map)}.")
  end
end
