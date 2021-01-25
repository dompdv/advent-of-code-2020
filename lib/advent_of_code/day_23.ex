defmodule AdventOfCode.Day23 do
  def part1(args) do
    # Parse la chaine d'entrée
    circle = args |> String.graphemes() |> Enum.map(&String.to_integer/1)
    # Applique les mouvements
    size = Enum.count(circle) |> IO.inspect()

    Enum.reduce(1..100, circle, fn _, acc -> move(acc, size) end)
    # Formatte pour la sortie
    |> format()

    # 47382659
  end

  defp format(circle) do
    case circle |> Enum.chunk_by(fn x -> x == 1 end) do
      [l1, [1], l2] -> l2 ++ l1
      [[1], l1] -> l1
      [l1, [1]] -> l1
    end
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join()
  end

  defp tourne(x, size) do
    if x < 1, do: size + x, else: x
  end

  def move([current, c1, c2, c3 | rest], size) do
    dest_label = tourne(current - 1, size)

    dest_label =
      if dest_label == c1 or dest_label == c2 or dest_label == c3 do
        dest_label = tourne(current - 2, size)

        if dest_label == c1 or dest_label == c2 or dest_label == c3 do
          dest_label = tourne(current - 3, size)

          if dest_label == c1 or dest_label == c2 or dest_label == c3 do
            tourne(current - 4, size)
          else
            dest_label
          end
        else
          dest_label
        end
      else
        dest_label
      end

    dest = Enum.find_index(rest, fn x -> x == dest_label end)

    new_rest =
      List.insert_at(rest, dest + 1, c3)
      |> List.insert_at(dest + 1, c2)
      |> List.insert_at(dest + 1, c1)

    new_rest ++ [current]
  end

  def next(map, p) do
    map[p]
  end

  def part2(args) do
    circle =
      args
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)

    circle =
      Enum.reduce(10..1_000_000, Enum.reverse(circle), fn i, acc -> [i | acc] end)
      |> Enum.reverse()

    size = Enum.count(circle) |> IO.inspect()
    [f | r] = circle
    map = Enum.zip(circle, r ++ [f]) |> Map.new()

    res =
      Enum.reduce(1..10_000_000, {f, map}, fn _, {c, acc} ->
        acc = move2(acc, c, size)
        {acc[c], acc}
      end)

    {_n, final} = res
    {final[1], final[final[1]], final[1] * final[final[1]]}
    # {n, devide(final, 1, 1, [])}
  end

  def devide(map, start, current, acc) do
    next = map[current]
    if next == start, do: Enum.reverse(acc), else: devide(map, start, next, [next | acc])
  end

  def move2(map, current, size) do
    c1 = map[current]
    c2 = map[c1]
    c3 = map[c2]
    c4 = map[c3]

    dest_label = tourne(current - 1, size)

    dest_label =
      if dest_label == c1 or dest_label == c2 or dest_label == c3 do
        dest_label = tourne(current - 2, size)

        if dest_label == c1 or dest_label == c2 or dest_label == c3 do
          dest_label = tourne(current - 3, size)

          if dest_label == c1 or dest_label == c2 or dest_label == c3 do
            tourne(current - 4, size)
          else
            dest_label
          end
        else
          dest_label
        end
      else
        dest_label
      end

    next_dest = map[dest_label]
    %{map | current => c4, dest_label => c1, c3 => next_dest}
  end
end
