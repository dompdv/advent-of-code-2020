defmodule AdventOfCode.Day23 do
  def part1(args) do
    # Parse la chaine d'entrée
    circle = args |> String.graphemes() |> Enum.map(&String.to_integer/1)
    # Applique les mouvements
    Enum.reduce(1..100, circle, fn _, acc -> move(acc) end)
    # Formatte pour la sortie
    |> format()
  end

  defp format(circle) do
    case circle |> Enum.chunk_by(fn x -> x==1 end) do
      [l1, [1], l2] -> (l2 ++ l1)
      [[1], l1] -> l1
      [l1, [1]] -> l1
    end
    |> Enum.map(&Integer.to_string/1) |> Enum.join()
  end
  def move([current, c1, c2, c3 | rest]) do
    dest_label = current +
      Enum.reduce_while(
        -1..-10,
        0,
        fn x, _acc -> if Enum.member?(rest, rem(10 + current + x, 10)), do: {:halt, x}, else: {:cont, x} end
        )
    dest_label = rem(dest_label + 10, 10)
    dest = Enum.find_index(rest, fn x -> x == dest_label end)
    new_rest = List.insert_at(rest, dest + 1, [c1, c2, c3]) |> List.flatten()
    new_rest ++ [current]
  end

  def part2(args) do
    args
  end
end
