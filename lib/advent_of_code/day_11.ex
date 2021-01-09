defmodule AdventOfCode.Day11 do
  def part1(args) do
    parse1(args) |> run_until_stabilization(4)
  end

  def part2(args) do
    parse2(args) |> run_until_stabilization(5)
  end

  defp run_until_stabilization(waiting_area, min_seats) do
    initial_state = for(i <- Map.keys(waiting_area), do: {i, 0}) |> Map.new()

    [{_, _, stable_state, _}] =
      Stream.iterate({waiting_area, true, initial_state, min_seats}, &tick/1)
      |> Stream.drop_while(fn {_, modified, _, _} -> modified end)
      |> Enum.take(1)

    Enum.sum(Map.values(stable_state))
  end

  defp tick({area, _, state, min_seats}) do
    new_state =
      for i <- Map.keys(area) do
        adjacent_seats = Enum.sum(Enum.map(area[i], fn seat -> state[seat] end))

        cond do
          state[i] == 0 and adjacent_seats == 0 -> {i, 1, true}
          state[i] == 1 and adjacent_seats >= min_seats -> {i, 0, true}
          true -> {i, state[i], false}
        end
      end

    modified = Enum.any?(new_state, fn {_, _, m} -> m end)
    {area, modified, Enum.map(new_state, fn {i, v, _} -> {i, v} end) |> Map.new(), min_seats}
  end

  defp is_seat(input, rows, cols, r, c) do
    cond do
      r < 0 or c < 0 or r >= rows or c >= cols ->
        false

      true ->
        case Enum.at(input, r) |> String.at(c) do
          "L" -> true
          _ -> false
        end
    end
  end

  defp convert_to_ds(rows, cols, input) do
    for r <- 0..(rows - 1), c <- 0..(cols - 1), is_seat(input, rows, cols, r, c) do
      adjacent_seats =
        for {dr, dc} <- [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}],
            is_seat(input, rows, cols, r + dr, c + dc) do
          (r + dr) * cols + (c + dc)
        end

      {r * cols + c, adjacent_seats}
    end
    |> Map.new()
  end

  defp parse_raw(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn s -> String.trim(s) end)
  end

  defp parse1(input) do
    raw_input = parse_raw(input)
    rows = Enum.count(raw_input)
    cols = String.length(List.first(raw_input))
    convert_to_ds(rows, cols, raw_input)
  end

  defp is_seat_in_direction(input, rows, cols, r, c, dr, dc) do
    m = max(rows, cols)

    n =
      1..m |> Enum.drop_while(fn n -> not is_seat(input, rows, cols, r + n * dr, c + n * dc) end)

    cond do
      Enum.count(n) == 0 ->
        {false, 0, 0}

      true ->
        n = hd(n)
        {true, r + n * dr, c + n * dc}
    end
  end

  defp convert_to_ds2(rows, cols, input) do
    for r <- 0..(rows - 1), c <- 0..(cols - 1), is_seat(input, rows, cols, r, c) do
      adjacent_seats =
        Enum.reduce(
          [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}],
          [],
          fn {dr, dc}, acc ->
            {is_seat, sr, sc} = is_seat_in_direction(input, rows, cols, r, c, dr, dc)
            if is_seat, do: [sr * cols + sc | acc], else: acc
          end
        )

      {r * cols + c, adjacent_seats}
    end
    |> Map.new()
  end

  defp parse2(input) do
    raw_input = parse_raw(input)
    rows = Enum.count(raw_input)
    cols = String.length(List.first(raw_input))
    convert_to_ds2(rows, cols, raw_input)
  end
end
