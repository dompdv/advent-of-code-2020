defmodule AdventOfCode.Day02 do
  def part1(args) do
    passwords = parse_input(args)
    Enum.count(passwords, &is_valid_p1(&1))
  end

  def part2(_args) do
  end

  defp is_valid_p1({low, high, letter, password}) do
    number = Enum.count(String.graphemes(password), fn c -> c == letter end)
    low <= number && number <= high
  end

  defp parse_line([a, b, c]) do
    [{low, _}, {high, _}] = String.split(a, "-") |> Enum.map(&Integer.parse/1)
    {low, high, String.at(b, 0), c}
  end

  defp parse_input(args) do
    String.split(args)
    |> Enum.chunk_every(3)
    |> Enum.map(&parse_line/1)
  end
end
