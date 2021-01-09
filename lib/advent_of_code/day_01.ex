defmodule AdventOfCode.Day01 do
  def part1(args) do
    expenses = Enum.sort(parse_input(args))
    # Enum.map(expenses, &(IO.inspect(&1)))
    {:ok, result} = narrow(expenses, 2020)
    result
  end

  def part2(args) do
    expenses = Enum.sort(parse_input(args))
    {:ok, result} = scan(expenses, 2020)
    result
  end

  defp parse_input(args) do
    String.split(args)
    |> Enum.map(&Integer.parse(&1))
    |> Enum.map(&elem(&1, 0))
  end

  defp scan([], _target) do
    nil
  end

  defp scan([h | r], target) do
    case narrow(r, target - h) do
      {:ok, result} -> {:ok, h * result}
      _ -> scan(r, target)
    end
  end

  defp narrow([], _target) do
    nil
  end

  defp narrow(expenses, target) do
    f = List.first(expenses)
    l = List.last(expenses)
    t = f + l

    cond do
      t == target -> {:ok, f * l}
      t < target -> narrow(Enum.slice(expenses, 1..-1), target)
      true -> narrow(Enum.slice(expenses, 0..-2), target)
    end
  end
end
