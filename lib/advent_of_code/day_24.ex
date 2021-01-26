defmodule AdventOfCode.Day24 do
  def part1(args) do
    parse(args)
    |> Enum.reduce(%{}, fn moves, acc -> flip(acc, moves) end)
    |> Enum.filter(fn {_, t} -> t == 1 end)
    |> Enum.count()
  end

  def part2(args) do
    starting_art =
      parse(args)
      |> Enum.reduce(%{}, fn moves, acc -> flip(acc, moves) end)

    Enum.reduce(1..100, starting_art, fn _, acc -> flip_all(acc) end) |> Enum.count()
  end

  def clean(tiles) do
    tiles |> Enum.filter(fn {_, t} -> t == 1 end) |> Map.new()
  end

  def new_state({x, y} = cell, tiles) do
    # Nombre de noirs (1 = noir, 0 = blanc) atour
    surroundings =
      [{2, 0}, {1, -1}, {-1, -1}, {-2, 0}, {-1, 1}, {1, 1}]
      |> Enum.map(fn {dx, dy} -> Map.get(tiles, {x + dx, y + dy}, 0) end)
      |> Enum.sum()
    # Règle de transition
    case Map.get(tiles, cell, 0) do
      0 -> if surroundings == 2, do: 1, else: 0
      1 -> if surroundings == 0 or surroundings > 2, do: 0, else: 1
    end
  end

  def flip_all(tiles) do
    # Trouve l'espace à explorer
    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max_by(tiles, fn {{x, _y}, _} -> x end)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(tiles, fn {{_x, y}, _} -> y end)

    # Parcourt l'espace
    for(x <- (x_min - 2)..(x_max + 2), y <- (y_min - 2)..(y_max + 2), do: {x, y})
    # Sur un hexagonier, toutes les coordonnées ne sont pas utiles
    |> Stream.filter(fn {x, y} -> rem(x + y, 2) == 0 end)
    # Calcule la nouvelle valeur de chaque case
    |> Stream.map(fn cell -> {cell, new_state(cell, tiles)} end)
    |> Map.new()
    # Enleve les noirs pour gagner un peu de mémoire et peut être de temps
    |> clean()
  end

  def flip(tiles, moves) do
    dest = move(moves)
    current = Map.get(tiles, dest, 0)
    if current == 0, do: Map.put(tiles, dest, 1), else: Map.put(tiles, dest, 0)
  end

  def move(moves) do
    Enum.reduce(moves, {0, 0}, fn {dx, dy}, {x, y} -> {x + dx, y + dy} end)
  end

  defp parse_line(line), do: parse_line(String.graphemes(line), [])
  defp parse_line([], acc), do: Enum.reverse(acc)
  defp parse_line(["e" | rest], acc), do: parse_line(rest, [{2, 0} | acc])
  defp parse_line(["s", "e" | rest], acc), do: parse_line(rest, [{1, -1} | acc])
  defp parse_line(["s", "w" | rest], acc), do: parse_line(rest, [{-1, -1} | acc])
  defp parse_line(["w" | rest], acc), do: parse_line(rest, [{-2, 0} | acc])
  defp parse_line(["n", "w" | rest], acc), do: parse_line(rest, [{-1, 1} | acc])
  defp parse_line(["n", "e" | rest], acc), do: parse_line(rest, [{1, 1} | acc])

  defp parse(input) do
    String.split(input, "\n", trim: true) |> Enum.map(&parse_line/1)
  end
end
