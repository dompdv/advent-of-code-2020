defmodule AdventOfCode.Day20 do
  def part1(args) do
    tiles =
      parse(args) |> Enum.map(fn {number, tile} -> {number, process_tile(tile)} end) |> Map.new()

    a_tile = tiles[3079]
    side?(:top, 501, a_tile)
  end

  def part2(_args) do
  end

  def side?(:top, value, %{comb: comb, sides: sides} = tile) do
    if MapSet.member?(sides, value) do
      [c] = for {t, b, l, r} <- comb, t == value, do: {t, b, l, r}
      {true, %{comb: [c], sides: MapSet.new(Tuple.to_list(c))}}
    else
      {false, tile}
    end
  end

  def side?(:bottom, value, %{comb: comb, sides: sides} = tile) do
    if MapSet.member?(sides, value) do
      [c] = for {t, b, l, r} <- comb, b == value, do: {t, b, l, r}
      {true, %{comb: [c], sides: MapSet.new(Tuple.to_list(c))}}
    else
      {false, tile}
    end
  end

  def side?(:left, value, %{comb: comb, sides: sides} = tile) do
    if MapSet.member?(sides, value) do
      [c] = for {t, b, l, r} <- comb, l == value, do: {t, b, l, r}
      {true, %{comb: [c], sides: MapSet.new(Tuple.to_list(c))}}
    else
      {false, tile}
    end
  end

  def side?(:right, value, %{comb: comb, sides: sides} = tile) do
    if MapSet.member?(sides, value) do
      [c] = for {t, b, l, r} <- comb, r == value, do: {t, b, l, r}
      {true, %{comb: [c], sides: MapSet.new(Tuple.to_list(c))}}
    else
      {false, tile}
    end
  end

  def produce_rotations({t, b, l, r}) do
    {t, b, l, r} =
      {String.to_integer(t, 2), String.to_integer(b, 2), String.to_integer(l, 2),
       String.to_integer(r, 2)}

    MapSet.new([{t, b, l, r}, {l, r, b, t}, {b, t, r, l}, {r, l, t, b}])
  end

  defp process_tile(tile) do
    core =
      {top, bottom, left, right} = {
        List.first(tile),
        List.last(tile),
        for(line <- tile, do: String.first(line)) |> Enum.join(),
        for(line <- tile, do: String.last(line)) |> Enum.join()
      }

    flip_h = {String.reverse(top), String.reverse(bottom), right, left}
    flip_v = {bottom, top, String.reverse(left), String.reverse(right)}

    combinations =
      [produce_rotations(core), produce_rotations(flip_h), produce_rotations(flip_v)]
      |> Enum.reduce(MapSet.new(), fn x, acc -> MapSet.union(x, acc) end)

    %{
      comb: combinations,
      sides:
        combinations |> Enum.map(fn x -> Tuple.to_list(x) end) |> List.flatten() |> MapSet.new()
    }
  end

  def parse(input) do
    input
    |> String.replace("#", "1")
    |> String.replace(".", "0")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn tile ->
      [head | rest] = String.split(tile, "\n", trim: true)
      [_, number] = String.split(head, " ")
      {String.slice(number, 0..-2) |> String.to_integer(), rest}
    end)
  end
end
