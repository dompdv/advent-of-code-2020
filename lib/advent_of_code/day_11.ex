defmodule AdventOfCode.Day11 do
  def part1(args) do
    waiting_area = parse(args)
    state = (for i <- Map.keys(waiting_area), do: {i, 0}) |> Map.new()
    state
  end

  def part2(_rgs) do
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
