defmodule AdventOfCode.Day11 do
  def part1(args) do
    waiting_area = parse(args)
    initial_state = (for i <- Map.keys(waiting_area), do: {i, 0}) |> Map.new()
    [{_, _, stable_state}] =
      Stream.iterate({waiting_area, true, initial_state}, &tick/1)
      |> Stream.drop_while(fn {_, modified, _} -> modified end)
      |> Enum.take(1)
    Enum.sum(Map.values(stable_state))
 end

  def part2(_rgs) do
  end

  defp tick({area, _ , state}) do
    new_state =
      (for i <- Map.keys(area) do
      adjacent_seats = Enum.sum(Enum.map(area[i], fn seat -> state[seat] end))
      cond do
        state[i] == 0 and adjacent_seats == 0 -> {i, 1, true}
        state[i] == 1 and adjacent_seats >= 4 -> {i, 0, true}
        true -> {i, state[i], false}
      end
    end)
    modified = Enum.any?(new_state, fn {_, _, m} -> m end)
    {area, modified, Enum.map(new_state, fn {i, v, _} -> {i, v} end) |> Map.new()}
  end

  defp is_seat(input, rows, cols, r, c) do
    cond do
      r < 0 or c < 0 or r >= rows or c >= cols -> false
      true ->
        case Enum.at(input, r) |> String.at(c) do
            "L" -> true
            _ -> false
        end
    end
  end

  defp convert_to_ds(rows, cols, input) do
    for r <- 0..(rows - 1), c <- 0..(cols - 1), is_seat(input, rows, cols, r, c)  do
      adjacent_seats =
            for {dr, dc} <- [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}],
              is_seat(input, rows, cols, r + dr, c + dc) do
              (r + dr) * cols + (c + dc)
            end
      {r * cols + c, adjacent_seats}
    end
    |> Map.new()
  end

  defp parse(input) do
    raw_input =
      input
      |> String.split("\n")
      |> Enum.filter(&(&1 != ""))
      |> Enum.map(fn s -> String.trim(s) end)
      rows = Enum.count(raw_input)
      cols = String.length(List.first(raw_input))
      convert_to_ds(rows, cols, raw_input)
  end

end
