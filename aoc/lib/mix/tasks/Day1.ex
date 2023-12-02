defmodule Mix.Tasks.Day1 do
  use Mix.Task

  @input_path "input.txt"
  @digits %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def read_input() do
    __ENV__.file
    |> Path.dirname()
    |> Path.join(@input_path)
    |> File.read!()
    |> String.trim_trailing("\n")
    |> String.split("\n")
  end

  def find_digit(substring, include_spelled) do
    @digits
    |> Enum.find_value(fn {key, value} ->
      cond do
        include_spelled and String.starts_with?(substring, key) -> value
        String.starts_with?(substring, value) -> value
        true -> nil
      end
    end)
  end

  def read_digit(token, range, include_spelled) do
    range
    |> Enum.reduce_while(nil, fn index, default ->
      digit =
        token
        |> String.slice(index..-1)
        |> find_digit(include_spelled)

      if digit != nil do
        {:halt, digit}
      else
        {:cont, default}
      end
    end)
  end

  def part_one(input) do
    input
    |> Enum.reduce(0, fn token, sum ->
      length = String.length(token)
      front_digit = read_digit(token, 0..(length - 1), false)
      back_digit = read_digit(token, (length - 1)..0, false)
      sum + String.to_integer(front_digit <> back_digit)
    end)
  end

  def part_two(input) do
    input
    |> Enum.reduce(0, fn token, sum ->
      length = String.length(token)
      front_digit = read_digit(token, 0..(length - 1), true)
      back_digit = read_digit(token, (length - 1)..0, true)
      sum + String.to_integer(front_digit <> back_digit)
    end)
  end

  def run(_) do
    input = read_input()
    IO.puts("Part one: #{part_one(input)}.")
    IO.puts("Part two: #{part_two(input)}.")
  end
end
