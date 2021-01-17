defmodule AdventOfCode.Day20 do
  def part1(args) do
    tiles = parse(args) |> Enum.map(fn {number, tile} -> {number, process_tile(tile)} end)
    square_size = :math.sqrt(Enum.count(tiles)) |> trunc()

    flat_tiles =
      tiles
      |> Enum.map(fn {number, tile} ->
        for comb <- tile, do: {number, comb, MapSet.new(Tuple.to_list(comb))}
      end)
      |> List.flatten()

    find_solution(%{}, square_size, {0, 0}, flat_tiles)
  end

  def part2(_args) do
  end

  def find_solution(pavage, square_size, {row, col}, tiles) do
    # si tout le pavage est rempli, alors on a trouvé une solution
    if row == square_size do
      pavage
    else
      # Sinon, considérons le carreau (tile) au dessus et le carreau à gauche de la position courante, s'ils existent
      {up, left} = {pavage[{row - 1, col}], pavage[{row, col - 1}]}

      tiles =
        if up do
          # S'il y a un carreau au dessus, on réduit la liste des possibilités (tiles) des carreaux compatibles
          {_number, {_t, b, _l, _r}, _mapset} = up
          # garder les carreaux dont le t(op) est égale au (b)ottom du carreau du dessus
          tiles
          |> Enum.filter(fn {_number, {t, _b, _l, _r}, _edges} -> t == b end)
        else
          tiles
        end

      tiles =
        if left do
          {_number, {_t, _b, _l, r}, _mapset} = left

          tiles
          |> Enum.filter(fn {_number, {_t, _b, l, _r}, _edges} -> l == r end)
        else
          tiles
        end

      if Enum.empty?(tiles) do
        # Si l'on n'a pas de possibilités, c'est qu'on a fait choux blanc
        nil
      else
        next_cell = if col == square_size - 1, do: {row + 1, 0}, else: {row, col + 1}

        tiles
        |> Enum.reduce_while(0, fn {number, _, _} = tile, _acc ->
          tiles_without_current_tile = tiles |> Enum.filter(fn {n, _, _} -> n != number end)

          res =
            find_solution(
              Map.put(pavage, next_cell, tile),
              square_size,
              next_cell,
              tiles_without_current_tile
            )

          if res, do: {:halt, res}, else: {:cont, 0}
        end)
      end
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

    [produce_rotations(core), produce_rotations(flip_h), produce_rotations(flip_v)]
    |> Enum.reduce(MapSet.new(), fn x, acc -> MapSet.union(x, acc) end)
    |> MapSet.to_list()
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
