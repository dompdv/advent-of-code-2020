defmodule AdventOfCode.Day17 do

  def part1(args) do
    active_cells = parse(args)
    Enum.reduce(1..6, active_cells, &tick/2)
    |> Enum.count()
  end

  def part2(_args) do
  end

  defp activate?({x, y, z} = cell, active_cells) do
    neighbors = Enum.sum(for dx <- -1..1, dy <- -1..1, dz <- -1..1, {dx, dy, dz} != {0,0,0}, do: if {x+dx, y+dy, z+dz} in active_cells, do: 1, else: 0)
    cond do
      cell in active_cells and (neighbors == 2 or neighbors == 3) -> true
      (not (cell in active_cells)) and (neighbors == 3) -> true
      true -> false
    end
  end

  defp tick(_, active_cells) do
    cell_to_consider(MapSet.to_list(active_cells), MapSet.new())
    |> Enum.filter(fn cell -> activate?(cell, active_cells) end)
    |> MapSet.new()
  end

  defp cell_to_consider([], cells), do: cells
  defp cell_to_consider([{x, y, z} | other], cells) do
    new_cells = for dx <- -1..1, dy <- -1..1, dz <- -1..1, {dx, dy, dz} != {0,0,0}, into: MapSet.new(), do: {x+dx, y+dy, z+dz}
    cell_to_consider(other, MapSet.union(cells, new_cells) )
  end

  defp build_coord_list([], cells), do: cells
  defp build_coord_list([{line, y} | rest], cells) do
    active_in_line =
      line |> String.graphemes() |> Enum.with_index()
      |> Enum.filter(fn {c, _i} -> c == "#" end)
      |> Enum.map(fn {_, i} -> {i, y, 0} end)
      |> MapSet.new()
    build_coord_list(rest, MapSet.union(cells, active_in_line))
  end


  defp parse(input) do
    input
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> build_coord_list(MapSet.new())
  end

end
