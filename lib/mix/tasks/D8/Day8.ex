defmodule Mix.Tasks.Day8 do
  use Mix.Task
  import InputUtils

  @input_path "input.txt"

  defmodule MapTrace do
    defstruct [
      :start_path,
      :end_paths,
      :directions,
      :directions_length,
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
    if Enum.at(directions, direction_index) === "L", do: 0, else: 1
  end

  def trace_path(map, map_trace) do
    output_index = direction_to_output_index(map_trace.directions, map_trace.direction_index)

    end_path =
      map
      |> Map.get(:nodes)
      |> Map.get(map_trace.start_path)
      |> Enum.at(output_index)

    map_trace_updated = %{
      map_trace
      | start_path: end_path,
        direction_index: rem(map_trace.direction_index + 1, map_trace.directions_length),
        step_count: map_trace.step_count + 1
    }

    if Enum.member?(map_trace.end_paths, map_trace.start_path) do
      map_trace.step_count
    else
      trace_path(map, map_trace_updated)
    end
  end

  def collect_terminal_nodes(map) do
    map
    |> Map.get(:nodes)
    |> Map.keys()
    |> Enum.reduce({[], []}, fn path, {start_paths, end_paths} ->
      cond do
        String.ends_with?(path, "A") -> {[path | start_paths], end_paths}
        String.ends_with?(path, "Z") -> {start_paths, [path | end_paths]}
        true -> {start_paths, end_paths}
      end
    end)
  end

  def part_one(map) do
    directions = Map.get(map, :directions)

    trace_path(
      map,
      %MapTrace{
        start_path: "AAA",
        end_paths: ["ZZZ"],
        directions: directions,
        directions_length: length(directions)
      }
    )
  end

  def part_two(map) do
    {start_paths, end_paths} = collect_terminal_nodes(map)
    directions = Map.get(map, :directions)

    start_paths
    |> Parallel.map(fn path ->
      trace_path(
        map,
        %MapTrace{
          start_path: path,
          end_paths: end_paths,
          directions: directions,
          directions_length: length(directions)
        }
      )
    end)
    |> then(fn step_counts ->
      tl(step_counts)
      |> Enum.reduce(Enum.at(step_counts, 0), fn count, gcd ->
        trunc(gcd * count / Integer.gcd(gcd, count))
      end)
    end)
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path, "\n\n")
    map = parse_map(input)
    IO.puts("Part one: #{part_one(map)}.")
    IO.puts("Part two: #{part_two(map)}.")
  end
end
