defmodule Mix.Tasks.Day9 do
  use Mix.Task
  import InputUtils

  @input_path "input.txt"

  def compute_next_base(row) do
    {_, deltas} =
      row
      |> tl()
      |> Enum.reduce({hd(row), []}, fn element, {prev_element, deltas} ->
        {element, deltas ++ [element - prev_element]}
      end)

    deltas
  end

  def parse_rows(input) do
    input
    |> Enum.map(fn row ->
      row
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def compute_deltas(last_bases, delta_sample_index, last_deltas \\ []) do
    if Enum.all?(last_bases, fn item -> item === 0 end) do
      last_deltas
    else
      compute_deltas(
        compute_next_base(last_bases),
        delta_sample_index,
        [Enum.at(last_bases, delta_sample_index) | last_deltas]
      )
    end
  end

  def predict_value(rows, direction_index, reduce_operation) do
    rows
    |> Enum.map(fn row ->
      row
      |> compute_deltas(direction_index)
      |> Enum.reduce(0, reduce_operation)
    end)
    |> Enum.sum()
  end

  def part_one(rows) do
    predict_value(rows, -1, &(&1 + &2))
  end

  def part_two(rows) do
    predict_value(rows, 0, &(&1 - &2))
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    rows = parse_rows(input)
    IO.puts("Part one: #{part_one(rows)}.")
    IO.puts("Part two: #{part_two(rows)}.")
  end
end
