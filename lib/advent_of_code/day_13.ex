defmodule AdventOfCode.Day13 do
  def part1(args) do
    {departure, buses} = parse(args)
    next_departures = Enum.map(buses, fn bus -> {bus, (div(departure, bus) + 1) * bus} end)
    {bus, time} = Enum.reduce(next_departures, fn {bus, time}, {mbus, mtime} -> if time < mtime, do: {bus, time}, else: {mbus, mtime} end)
    bus * (time - departure)
  end

  def part2(args) do
    [_, l2] =args |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    rules =
      l2
      |> String.split(",") |> Enum.with_index() |> Enum.filter(fn {v, _} -> v != "x" end)
      |> Enum.map(fn {v, i} -> {String.to_integer(v), i} end)
      |> Enum.sort(&(elem(&1, 0) <= elem(&2, 0)))
    IO.inspect(rules)
    first_time(1, rules)
  end

  defp first_time(mtime, [{bus, delta}]) do
    if rem(mtime + delta, bus) == 0 do
      mtime
    else
      (div(mtime + delta, bus) + 1) * bus - delta
    end

  end

  defp first_time(mtime, [{bus, delta} | rest] = rules) do
    #IO.inspect({mtime, {bus, delta}})
    #:timer.sleep(10)
    if rem(mtime + delta, bus) == 0 do
      new_mtime = first_time(mtime, rest)
      if new_mtime == mtime do
        mtime
      else
        first_time(new_mtime, rules)
      end
    else
      first_time((div(mtime + delta, bus) + 1) * bus - delta, rules)
    end
  end

  defp parse(input) do
    [l1, l2] =input |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    {String.to_integer(l1),
    l2 |> String.split(",") |> Enum.filter(&(&1 != "x")) |> Enum.map(&String.to_integer/1)}
  end

end
