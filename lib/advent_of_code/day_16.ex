defmodule AdventOfCode.Day16 do
  def part1(args) do
    {_, input} = parse(args)

    Enum.flat_map(input.nearby, fn x->x end)
    |> Enum.filter( &(not valid_number?(&1, input.rules)))
    |> Enum.sum()
  end

  def part2(_args) do
  end

  def valid_number?(number, rules) do
    Enum.any?(rules,
            fn {_, ranges} -> Enum.any?(ranges, fn {l, h} -> l <= number and number <= h end) end)
  end

  defp parse(input) do
    input
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    |> Enum.reduce({:rules, %{rules: [], ticket: [], nearby: []}}, &parse_line/2)
  end

  defp parse_line(line, {:rules, acc}) do
    cond do
      line == "your ticket:" -> {:ticket, acc}
      line == "nearby tickets:" -> {:nearby, acc}
      true -> [class, rest] = String.split(line, ":")
              ranges = String.split(String.trim(rest), "or") |> Enum.map(&String.trim/1)
                      |> Enum.map(fn s -> [l, h] = String.split(s, "-")
                                          {String.to_integer(l) , String.to_integer(h)} end)
              {:rules, %{acc | rules: [{class, ranges} | acc.rules]}}
    end
  end
  defp parse_line(line, {:ticket, acc}) do
    cond do
      line == "nearby tickets:" -> {:nearby, acc}
      true -> fields = String.split(line, ",") |> Enum.map(&String.to_integer/1)
              {:ticket, %{acc | ticket: fields}}
    end
  end
  defp parse_line(line, {:nearby, acc}) do
    fields = String.split(line, ",") |> Enum.map(&String.to_integer/1)
    {:nearby, %{acc | nearby: [fields | acc.nearby]}}
  end
end
