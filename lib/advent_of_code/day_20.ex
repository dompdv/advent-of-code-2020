defmodule AdventOfCode.Day20 do
  def part1(args) do
    {sol, square_size} = compute_solution(args)
    h = square_size - 1

    Enum.map([{0, 0}, {0, h}, {h, 0}, {h, h}], fn
      c ->
        {n, _} = sol[c]
        n
    end)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def compute_solution(args) do
    tiles =
      parse(args)
      |> Enum.map(fn {number, tile} -> {number, process_tile(tile, true)} end)

    all_numbers =
      tiles
      |> Enum.map(fn {_, x} -> x end)
      |> List.flatten()
      |> Enum.map(&Tuple.to_list/1)
      |> List.flatten()
      |> Enum.frequencies()

    rank =
      tiles
      |> Enum.map(fn {number, tile} ->
        {number,
         hd(tile) |> Tuple.to_list() |> Enum.reduce(0, fn x, acc -> acc + all_numbers[x] end)}
      end)
      |> Map.new()

    square_size = :math.sqrt(Enum.count(tiles)) |> trunc()

    flat_tiles =
      tiles
      |> Enum.map(fn {number, tile} ->
        for comb <- tile, do: {number, comb}
      end)
      |> List.flatten()
      |> Enum.sort(fn {n1, _}, {n2, _} -> rank[n1] < rank[n2] end)

    {find_solution(%{}, square_size, {0, 0}, flat_tiles), square_size}
  end

  def part2(args) do
    tiles =
      parse(args)
      |> Enum.map(fn {number, tile} -> {number, process_tile(tile, false) |> Map.new()} end)
      |> Map.new()

    {sol, square_size} = compute_solution(args)
    h = square_size - 1

    tiled_sol =
      sol
      |> Enum.map(fn {cell, {tile, comb}} -> {cell, trim_matrix(tiles[tile][comb])} end)
      |> Map.new()

    line_per_tile = Enum.count(tiled_sol[{0, 0}])

    image =
      for r <- 0..(square_size * line_per_tile - 1),
          do:
            Enum.join(
              for c <- 0..h,
                  do: Enum.at(tiled_sol[{div(r, line_per_tile), c}], rem(r, line_per_tile))
            )
  end

  def trim_matrix(matrix) do
    matrix |> Enum.slice(1..-2) |> Enum.map(fn s -> String.slice(s, 1..-2) end)
  end

  def find_solution(pavage, square_size, {row, col}, tiles) do
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

      if Enum.empty?(filtered_tiles) do
        # Si l'on n'a pas de possibilités, c'est qu'on a fait choux blanc
        nil
      else
        next_cell = if col == square_size - 1, do: {row + 1, 0}, else: {row, col + 1}

        filtered_tiles
        |> Enum.reduce_while(
          0,
          fn {number, _} = tile, _acc ->
            tiles_without_current_tile = tiles |> Enum.filter(fn {n, _} -> n != number end)

            res =
              find_solution(
                Map.put(pavage, {row, col}, tile),
                square_size,
                next_cell,
                tiles_without_current_tile
              )

            if res == nil, do: {:cont, nil}, else: {:halt, res}
          end
        )
      end
    end
  end

  defp getrc(matrix, r, c) do
    Enum.at(matrix, r) |> String.at(c)
  end
  defp getrcs(matrix, l) do
    Enum.map(l, fn {r, c} -> getrc(matrix, r, c) end)
  end
  defp setrc(matrix, r, c, v) do
    List.update_at(matrix, r,
    fn row ->
      if c == 0 do
        s_after = String.slice(row, 1..-1)
        "#{v}#{s_after}"
      else
        s_before = String.slice(row, 0..(c - 1))
        s_after = String.slice(row, (c + 1)..-1)
        "#{s_before}#{v}#{s_after}"
      end
    end)
  end

  defp rotate90(matrix) do
    size = Enum.count(matrix) - 1

    Enum.map(0..size, fn l ->
      for(r <- 0..size, do: matrix |> Enum.at(r) |> Enum.at(l)) |> Enum.reverse()
    end)
  end

  defp flipv(matrix) do
    matrix |> Enum.map(fn l -> Enum.reverse(l) end)
  end

  defp fliph(matrix) do
    Enum.reverse(matrix)
  end

  defp produce_rotations(matrix) do
    matrix90 = rotate90(matrix)
    matrix180 = rotate90(matrix90)
    matrix270 = rotate90(matrix180)
    [matrix, matrix90, matrix180, matrix270]
  end

  defp to_tblr(tile) do
    {top, bottom, left, right} = {
      List.first(tile),
      List.last(tile),
      for(line <- tile, do: String.first(line)) |> Enum.join(),
      for(line <- tile, do: String.last(line)) |> Enum.join()
    }

    {String.to_integer(top, 2), String.to_integer(bottom, 2), String.to_integer(left, 2),
     String.to_integer(right, 2)}
  end

  defp to_str(tile) do
    Enum.map(tile, &Enum.join/1)
  end

  defp process_tile(tile, tblr_only) do
    core = tile |> Enum.map(&String.graphemes/1)
    flip_h = fliph(core)
    flip_v = flipv(core)

    combinations =
      (produce_rotations(core) ++ produce_rotations(flip_h) ++ produce_rotations(flip_v))
      |> Enum.map(fn tile -> to_str(tile) end)

    if tblr_only,
      do: combinations |> Enum.map(&to_tblr/1),
      else: Enum.zip(combinations |> Enum.map(&to_tblr/1), combinations)
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
