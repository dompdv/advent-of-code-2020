defmodule AdventOfCode.Day22 do
  def part1(args) do
    {deck1, deck2} = parse(args)

    play_game(deck1, deck2)
    |> winner()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {v, i}, acc -> acc + v * i end)
  end

  defp winner({p, []}), do: p
  defp winner({[], p}), do: p

  def play_game([], deck2), do: {[], deck2}
  def play_game(deck1, []), do: {deck1, []}

  def play_game([c1 | deck1], [c2 | deck2]) do
    if c1 > c2, do: play_game(deck1 ++ [c1, c2], deck2), else: play_game(deck1, deck2 ++ [c2, c1])
  end

  def part2(args) do
    {deck1, deck2} = parse(args)

    case play_rgame(deck1, deck2, MapSet.new()) do
      {:winner1, deck, _} -> deck
      {:winner2, _, deck} -> deck
    end
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {v, i}, acc -> acc + v * i end)
  end

  def play_rgame([], deck2, _), do: {:winner2, [], deck2}
  def play_rgame(deck1, [], _), do: {:winner1, deck1, []}

  def play_rgame([c1 | rest1] = deck1, [c2 | rest2] = deck2, history) do
    if MapSet.member?(history, {deck1, deck2}) do
      {:winner1, deck1, []}
    else
      history = MapSet.put(history, {deck1, deck2})

      if c1 <= Enum.count(rest1) and c2 <= Enum.count(rest2) do
        # Subgame
        case play_rgame(Enum.slice(deck1, 1..c1), Enum.slice(deck2, 1..c2), MapSet.new()) do
          {:winner1, _, _} -> play_rgame(rest1 ++ [c1, c2], rest2, history)
          {:winner2, _, _} -> play_rgame(rest1, rest2 ++ [c2, c1], history)
        end
      else
        # Normal game
        if c1 > c2,
          do: play_rgame(rest1 ++ [c1, c2], rest2, history),
          else: play_rgame(rest1, rest2 ++ [c2, c1], history)
      end
    end
  end

  defp parse_deck(deck) do
    [_ | cards] = String.split(deck, "\n", trim: true)
    cards |> Enum.map(&String.to_integer/1)
  end

  defp parse(input) do
    [p1, p2] = String.split(input, "\n\n", trim: true)
    {parse_deck(p1), parse_deck(p2)}
  end
end
