defmodule AdventOfCode.Day10 do
  def part1(args) do
    # Parse & sort
    adapters = parse(args) |> Enum.sort()
    # Add the plug and the adapter in the bag
    adapters = List.insert_at([0 | adapters], -1, Enum.max(adapters) + 3)
    # Create a list of tuple with 2 consecutive adapters
    [_| rest] = adapters
    jolt_diff = Enum.zip(adapters, rest) |> Enum.map(fn {l, h} -> h - l end)
    # Compute frequencies
    |> Enum.frequencies()
    # Et voilou
    jolt_diff[1] * jolt_diff[3]
  end

  def part2(_args) do
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn s -> String.trim(s) |> String.to_integer() end)
  end
end
