defmodule AdventOfCode.Day10 do
  def part1(args) do
    # Parse & sort
    adapters = parse(args) |> Enum.sort()
    # Add the plug and the adapter in the bag
    adapters = List.insert_at([0 | adapters], -1, Enum.max(adapters) + 3)
    # Create a list of tuple with 2 consecutive adapters
    [_ | rest] = adapters

    jolt_diff =
      Enum.zip(adapters, rest)
      |> Enum.map(fn {l, h} -> h - l end)
      # Compute frequencies
      |> Enum.frequencies()

    # Et voilou
    jolt_diff[1] * jolt_diff[3]
  end

  def part2(args) do
    # Parse & sort
    adapters = parse(args) |> Enum.sort()
    # Add the plug and the adapter in the bag
    adapters = List.insert_at([0 | adapters], -1, Enum.max(adapters) + 3) |> MapSet.new()

    max_value = Enum.max(adapters)

    acc =
      possibilities(
        Map.new(0..max_value, fn x ->
          if x == 0 do
            {x, 1}
          else
            {x, 0}
          end
        end),
        MapSet.new(adapters),
        Enum.to_list(0..max_value)
      )

    acc[max_value]
  end

  defp possibilities(acc, _adapters, []) do
    acc
  end

  defp possibilities(acc, adapters, [h | rest]) do
    v = acc[h]

    acc =
      if MapSet.member?(adapters, h + 1),
        do: Map.put(acc, h + 1, v + Map.get(acc, h + 1)),
        else: acc

    acc =
      if MapSet.member?(adapters, h + 2),
        do: Map.put(acc, h + 2, v + Map.get(acc, h + 2)),
        else: acc

    acc =
      if MapSet.member?(adapters, h + 3),
        do: Map.put(acc, h + 3, v + Map.get(acc, h + 3)),
        else: acc

    possibilities(acc, adapters, rest)
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn s -> String.trim(s) |> String.to_integer() end)
  end
end
