# TODO
# Find digits nearby symbol position. Only check digits that are y - 1, y, y + 1 of symbol position.
# Do the same digit processing as in part one.

defmodule Mix.Tasks.Day3 do
  use Mix.Task
  import InputUtils

  @input_path "input_sample.txt"
  @digits Enum.map(0..9, &Integer.to_string/1)

  defp get_dimensions(map_input) do
    width =
      map_input
      |> Enum.at(0)
      |> String.length()

    height = length(map_input)

    {width, height}
  end

  defp maybe_update_digit_buckets(row, y, buckets_total) do
    [buckets, _, _, _] =
      row
      |> Enum.reduce([%{}, 0, 0, false], fn cell, [bucket, x, bucket_index, last_cell_was_digit] ->
        cond do
          Enum.member?(@digits, cell) ->
            [
              Map.update(bucket, bucket_index, %{[x, y] => cell}, fn item ->
                Map.merge(item, %{[x, y] => cell})
              end),
              x + 1,
              bucket_index,
              true
            ]

          true ->
            if last_cell_was_digit do
              [bucket, x + 1, bucket_index + 1, false]
            else
              [bucket, x + 1, bucket_index, false]
            end
        end
      end)

    if map_size(buckets) !== 0 do
      Map.put(buckets_total, y, buckets)
    else
      buckets_total
    end
  end

  defp maybe_update_symbols_table(map, cell, position) do
    if cell !== "." and !Enum.member?(@digits, cell) do
      Map.put(map, position, cell)
    else
      map
    end
  end

  defp parse_map(map_input) do
    {width, height} = get_dimensions(map_input)

    [symbols, digits] =
      0..(height - 1)
      |> Enum.reduce([%{}, %{}], fn y, [symbols_outer, digits_outer] ->
        row = Enum.at(map_input, y) |> String.graphemes()

        0..(width - 1)
        |> Enum.reduce([symbols_outer, digits_outer], fn x, [symbols_inner, digits_inner] ->
          cell = Enum.at(row, x)

          [
            maybe_update_symbols_table(symbols_inner, cell, [x, y]),
            maybe_update_digit_buckets(row, y, digits_inner)
          ]
        end)
      end)

    {symbols, digits}
  end

  defp has_adjacent_symbols([x, y], symbols) do
    valid_positions = [
      [x - 1, y],
      [x + 1, y],
      [x, y + 1],
      [x, y - 1],
      [x - 1, y - 1],
      [x - 1, y + 1],
      [x + 1, y - 1],
      [x + 1, y + 1]
    ]

    Enum.any?(valid_positions, fn position -> Map.has_key?(symbols, position) end)
  end

  defp find_numbers_near_symbols(digits, symbols) do
    valid_digits =
      digits
      |> Map.values()
      |> Enum.reduce([], fn row_digits, valid_digits_outer ->
        row_digits
        |> Map.values()
        |> Enum.reduce(valid_digits_outer, fn digits, valid_digits_inner ->
          number_positions = Map.keys(digits)

          if Enum.any?(number_positions, fn position -> has_adjacent_symbols(position, symbols) end) do
            valid_digits_inner ++ [digits]
          else
            valid_digits_inner
          end
        end)
      end)

    valid_digits
  end

  defp find_gear_positions(symbols) do
    symbols
    |> Map.keys()
    |> Enum.reduce([], fn position, gears ->
      if Map.get(symbols, position) === "*" do
        [position | gears]
      else
        gears
      end
    end)
  end

  def collect_adjacent_digits([x, y], digits) do
    IO.puts("Collecting digits for symbol #{x}, #{y}.")
  end

  def find_gears(digits, symbols) do
    symbols
    |> find_gear_positions()
    |> Enum.map(fn [x, y] ->
      adjacent_digits = collect_adjacent_digits([x, y], digits)
#      nearby_digits = find_nearby_digits(digits, y)
#      IO.inspect(nearby_digits)

      []
    end)

#    IO.inspect(digits, charlists: :as_lists)
  end

  defp to_number(numbers) do
    numbers
    |> Map.to_list()
    |> Enum.sort_by(fn {[x, _], _} -> x end)
    |> Enum.map(fn {[_, _], value} -> value end)
    |> Enum.join()
    |> String.to_integer()
  end

  defp part_one(digits, symbols) do
    digits
    |> find_numbers_near_symbols(symbols)
    |> Enum.map(&to_number/1)
    |> Enum.sum()
  end

  defp part_two(digits, symbols) do
    find_gears(digits, symbols)
    :noop
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    {symbols, digits} = parse_map(input)
#    IO.puts("Part one: #{part_one(digits, symbols)}.")
    IO.puts("Part two: #{part_two(digits, symbols)}.")
  end
end
