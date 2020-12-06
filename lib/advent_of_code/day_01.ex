defmodule AdventOfCode.Day01 do
  def part1(args) do
    expenses = Enum.sort(parse_input(args))
    # Enum.map(expenses, &(IO.inspect(&1)))
    narrow(expenses, 2020)
  end

  def part2(_args) do
  end

  defp parse_input(args) do
    String.split(args)
    |> Enum.map(&Integer.parse(&1))
    |> Enum.map(&elem(&1,0))
  end

  defp narrow(expenses, target) do
    f = List.first(expenses)
    l = List.last(expenses)
    t =  f + l
    cond do
      t == target -> f * l
      t < target -> narrow(Enum.slice(expenses, 1..-1), target)
      true -> narrow(Enum.slice(expenses, 0..-2), target)
    end
  end
end
