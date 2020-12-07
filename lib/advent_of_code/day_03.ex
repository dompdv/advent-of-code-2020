defmodule AdventOfCode.Day03 do
  def part1(args) do
    a_map = parse_input(args)
    slide a_map, 0, 0, 1, 3
  end

  def part2(_args) do
  end

  defp slide(a_map, row, column, v_row, v_column) do
    rows = Enum.count(a_map)
    coordinates = for n <- 0..(div(rows, v_row) - 1), do: {row + n * v_row, column + n * v_column}
    Enum.count(coordinates, fn {r, c} -> tree?(a_map, r, c) end)
  end

  defp tree?(a_map, row, column) do
    width = List.first(a_map) |> String.length()
    Enum.at(a_map, row) |> String.at(rem(column, width)) == "#"
  end

  defp parse_input(args) do
    String.split(args)
#    |> Enum.map(&Integer.parse(&1))
#    |> Enum.map(&elem(&1,0))
  end


end
