defmodule AdventOfCode.Day20 do
  def part1(args) do
    tiles = parse(args) |> Enum.map(fn {number, tile} -> {number, process_tile(tile)} end)
    square_size = :math.sqrt(Enum.count(tiles)) |> trunc()

    flat_tiles =
      tiles
      |> Enum.map(fn {number, tile} ->
        for comb <- tile, do: {number, comb}
      end)
      |> List.flatten()

    IO.inspect(flat_tiles |> Enum.filter(fn {n, _} -> n == 3079 end))
    find_solution(%{}, square_size, {0, 0}, flat_tiles)
  end

  def part2(_args) do
  end

  def find_solution(pavage, square_size, {row, col}, tiles) do
    if row == 2 do
      IO.inspect({"find sol", pavage, square_size, {row, col}, tiles})
    end
    # si tout le pavage est rempli, alors on a trouvé une solution
    if row == square_size do
      pavage
    else
      # Sinon, considérons le carreau (tile) au dessus et le carreau à gauche de la position courante, s'ils existent
      {up, left} = {pavage[{row - 1, col}], pavage[{row, col - 1}]}

      filtered_tiles =
        tiles
        |> Enum.filter(fn {_number, {t, _b, l, _r}} ->
          cond_1 =
            if up do
              {_number, {_t, b, _l, _r}} = up
              t == b
            else
              true
            end

          cond_2 =
            if left do
              {_number, {_t, _b, _l, r}} = left
              l == r
            else
              true
            end

          cond_1 and cond_2
        end)

      IO.inspect({"Tiles", Enum.count(filtered_tiles)})

      if Enum.empty?(filtered_tiles) do
        # Si l'on n'a pas de possibilités, c'est qu'on a fait choux blanc
        nil
      else
        next_cell = if col == square_size - 1, do: {row + 1, 0}, else: {row, col + 1}
        IO.inspect("Reduce while")

        filtered_tiles
        |> Enum.reduce_while(
          0,
          fn {number, _} = tile, _acc ->
            IO.inspect({"Consider tile", tile})
            tiles_without_current_tile = tiles |> Enum.filter(fn {n, _} -> n != number end)

            res =
              find_solution(
                Map.put(pavage, {row, col}, tile),
                square_size,
                next_cell,
                tiles_without_current_tile
              )

            IO.inspect({"retour", res})
            if res == nil, do: {:cont, nil}, else: {:halt, res}
          end
        )
      end
    end
  end

  def produce_rotations({t, b, l, r}) do
    #{t, b, l, r} = {String.to_integer(t, 2), String.to_integer(b, 2), String.to_integer(l, 2), String.to_integer(r, 2)}
    [{t, b, l, r}, {l, r, b, t}, {b, t, r, l}, {r, l, t, b}]
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
    #flip_d = {String.reverse(bottom), String.reverse(top), String.reverse(right), String.reverse(left)}
    [produce_rotations(core), produce_rotations(flip_h), produce_rotations(flip_v)] #, produce_rotations(flip_d)]
    |> List.flatten()
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
