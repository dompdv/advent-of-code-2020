defmodule AdventOfCode.Day13 do
  def part1(args) do
    {departure, buses} = parse(args)
    next_departures = Enum.map(buses, fn bus -> {bus, (div(departure, bus) + 1) * bus} end)
    {bus, time} = Enum.reduce(next_departures, fn {bus, time}, {mbus, mtime} -> if time < mtime, do: {bus, time}, else: {mbus, mtime} end)
    bus * (time - departure)
  end

  def part2(_args) do
  end

  defp parse(input) do
    [l1, l2] =input |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    {String.to_integer(l1),
    l2 |> String.split(",") |> Enum.filter(&(&1 != "x")) |> Enum.map(&String.to_integer/1)}
  end

end
