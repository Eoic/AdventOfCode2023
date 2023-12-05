defmodule Mix.Tasks.Day4 do
  use Mix.Task
  import InputUtils

  @input_path "input.txt"

  def parse_cards(input) do
    input
    |> Enum.map(fn row ->
      [winning_card_text, current_card_text] = String.split(row, " | ")

      winning_card =
        winning_card_text
        |> String.split(": ")
        |> Enum.at(1)
        |> String.trim()
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      current_card =
        current_card_text
        |> String.trim()
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      [winning_card, current_card, count_matches(winning_card, current_card)]
    end)
  end

  defp count_matches(winning_numbers, hand_numbers) do
    hand_numbers
    |> Enum.reduce(0, fn number, count ->
      count + if Enum.member?(winning_numbers, number), do: 1, else: 0
    end)
  end

  defp get_score(matches) do
    cond do
      matches > 1 -> :math.pow(2, matches - 1) |> trunc()
      true -> matches
    end
  end

  defp count_winnings(card_pairs) do
    card_pairs
    |> Enum.reduce(0, fn [_, _, matches], score ->
      score + get_score(matches)
    end)
  end

  defp clamp(value, min_value, max_value) do
    min(max(value, min_value), max_value)
  end

  defp copy_card_ids(card_id, matches, original_size) do
    clamp(card_id + 1, card_id, original_size)..clamp(card_id + matches, card_id + 1, original_size)
  end

  defp process_cards(original_pairs, original_size, card_quantities) do
    card_quantities
    |> Map.keys()
    |> Enum.reduce(%{}, fn card_id, updated_card_quantities ->
      {[_, _, matches], _} = Enum.at(original_pairs, card_id - 1)

      initial_count = Map.get(card_quantities, card_id)

      if matches > 0 do
        card_id
        |> copy_card_ids(matches, original_size)
        |> Enum.reduce(updated_card_quantities, fn copied_card_id, quantities ->
          Map.update(quantities, copied_card_id, initial_count, fn count -> count + initial_count end)
        end)
      else
        updated_card_quantities
      end
    end)
  end

  def count_won_cards(original_pairs, deck_size, card_quantities, total_count \\ 0)

  def count_won_cards(original_pairs, deck_size, card_quantities, total_count) do
    won_card_quantities = process_cards(original_pairs, deck_size, card_quantities)
    won_count = Map.values(won_card_quantities) |> Enum.sum()

    if won_count === 0 do
      total_count + deck_size
    else
      count_won_cards(original_pairs, deck_size, won_card_quantities, total_count + won_count)
    end
  end

  defp part_one(card_pairs) do
    count_winnings(card_pairs)
  end

  defp part_two(card_pairs) do
    deck_size = length(card_pairs)
    indexed_card_pairs = Enum.with_index(card_pairs, 1)

    card_quantities =
      indexed_card_pairs
      |> Enum.reduce(%{}, fn {_, card_id}, quantities -> Map.put(quantities, card_id, 1) end)

    count_won_cards(indexed_card_pairs, deck_size, card_quantities)
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    card_pairs = parse_cards(input)
    IO.puts("Part one: #{part_one(card_pairs)}.")
    IO.puts("Part two: #{part_two(card_pairs)}.")
  end
end
