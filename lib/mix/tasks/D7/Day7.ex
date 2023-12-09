defmodule Mix.Tasks.Day7 do
  use Mix.Task
  import InputUtils

  @input_path "input.txt"

  @card_strengths %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "J" => 11,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2
  }

  defp is_five_of_a_kind?(hand) do
    hand
    |> Enum.uniq()
    |> Enum.count()
    |> (&(&1 === 1)).()
  end

  defp is_four_of_a_kind?(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.member?(4)
  end

  defp is_full_house?(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> (&(Enum.member?(&1, 3) and length(&1) === 2)).()
  end

  defp is_three_of_a_kind?(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> (&(Enum.member?(&1, 3) and length(&1) === 3)).()
  end

  defp is_two_pair?(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> (&(length(&1) === 3 and Enum.count(&1, fn freq -> freq === 2 end) === 2)).()
  end

  defp is_one_pair?(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> (&(length(&1) === 4 and Enum.member?(&1, 2))).()
  end

  defp is_high_card?(hand) do
    hand
    |> Enum.frequencies()
    |> Map.values()
    |> (&(length(&1) === 5)).()
  end

  defp upgrade_hand_by_wildcard(hand) do
    if Enum.uniq(hand) |> length() === 1 do
      Enum.map(hand, fn _ -> "A" end)
    else
      {key, _} =
        hand
        |> Enum.filter(fn card -> card !== "J" end)
        |> Enum.frequencies()
        |> Enum.max_by(fn {_, value} -> value end)

      Enum.map(hand, fn item ->
        if item === "J" do
          key
        else
          item
        end
      end)
    end
  end

  defp get_hand_score(hand, with_wildcards) do
    current_hand =
      if with_wildcards and Enum.member?(hand, "J") do
        upgrade_hand_by_wildcard(hand)
      else
        hand
      end

    [
      &is_five_of_a_kind?/1,
      &is_four_of_a_kind?/1,
      &is_full_house?/1,
      &is_three_of_a_kind?/1,
      &is_two_pair?/1,
      &is_one_pair?/1,
      &is_high_card?/1
    ]
    |> Enum.with_index(1)
    |> Enum.find_value(fn {predicate, score} ->
      if predicate.(current_hand), do: 8 - score
    end)
  end

  defp parse_hands(input) do
    input
    |> Enum.map(fn hand_data ->
      [hand, bid] = String.split(hand_data, " ", trim: true)

      %{
        :cards => String.graphemes(hand),
        :bid => String.to_integer(bid)
      }
    end)
  end

  defp compare_same_type_hands(left_hand, right_hand, card_strengths) do
    0..4
    |> Enum.reduce_while(0, fn index, comp ->
      left_hand_card = left_hand.cards |> Enum.at(index)
      right_hand_card = right_hand.cards |> Enum.at(index)
      score_left = Map.get(card_strengths, left_hand_card)
      score_right = Map.get(card_strengths, right_hand_card)

      cond do
        score_left > score_right -> {:halt, 1}
        score_left < score_right -> {:halt, -1}
        score_left === score_right -> {:cont, comp}
      end
    end)
  end

  defp calculate_winnings(hands, with_wildcards \\ false) do
    card_strengths =
      if with_wildcards do
        Map.put(@card_strengths, "J", 1)
      else
        @card_strengths
      end

    hands
    |> Enum.sort_by(& &1, fn left_hand, right_hand ->
      left_score = get_hand_score(left_hand.cards, with_wildcards)
      right_score = get_hand_score(right_hand.cards, with_wildcards)

      cond do
        left_score > right_score ->
          false

        left_score < right_score ->
          true

        left_score === right_score ->
          compare_same_type_hands(left_hand, right_hand, card_strengths) <= 0
      end
    end)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {hand, rank}, winnings ->
      winnings + Map.get(hand, :bid) * rank
    end)
  end

  defp part_one(hands) do
    calculate_winnings(hands)
  end

  defp part_two(hands) do
    calculate_winnings(hands, true)
  end

  def run(_) do
    input = read_input_into_lines(__ENV__.file, @input_path)
    hands = parse_hands(input)
    IO.puts("Part one: #{part_one(hands)}.")
    IO.puts("Part two: #{part_two(hands)}.")
  end
end
