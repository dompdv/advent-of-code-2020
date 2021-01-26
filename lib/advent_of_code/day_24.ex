defmodule AdventOfCode.Day24 do
  def part1(args) do
    parse(args)
    |> Enum.reduce(%{}, fn moves, acc -> flip(acc, moves) end)
    |> Enum.filter(fn {_, t} -> t == 1 end)
    |> Enum.count()
  end

  def flip(tiles, moves) do
    dest = move(moves)
    current = Map.get(tiles, dest, 0)
    if current == 0, do: Map.put(tiles, dest, 1), else: Map.put(tiles, dest, 0)
  end

  def move(moves) do
    Enum.reduce(moves, {0, 0}, fn {dx, dy}, {x, y} -> {x + dx, y + dy} end)
  end

  def part2(args) do
    args
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
