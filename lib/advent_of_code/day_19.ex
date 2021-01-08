defmodule AdventOfCode.Day19 do
  def part1(args) do
    parse(args)
  end

  def part2(_args) do
  end

  defp to_list(s) do
    s |> String.trim() |> String.split(" ") |> Enum.map(fn x-> String.to_integer(String.trim(x)) end)
  end
  @spec parse_rules(binary) :: map
  def parse_rules(rules) do
    rules |> String.split("\n") |> Enum.map(fn x -> x |> String.trim |> String.split(":") end)
    |> Enum.map(fn [rule_number, r] -> {String.to_integer(rule_number), String.trim(r)} end)
    |> Enum.map(
      fn {rule_number, r} ->
        cond do
          String.contains?(r, ~s(")) -> [_, msg, _] = String.split(r, ~s("))
                                        {rule_number, {:msg, msg}}
          String.contains?(r, "|") ->   [left, right] = String.split(r, "|")
                                        {rule_number, {:alt, to_list(left), to_list(right)}}
          true -> {rule_number, {:rule, to_list(r)}}
        end
    end)
    |> Map.new()

  end
  def parse_msg(rules) do
    rules |> String.split("\n") |> Enum.map(&String.trim/1) |> Enum.filter(fn x -> x != "" end)
  end

  def parse(input) do
    [rules, msg] = String.split(input, "\n\n")
    {parse_rules(rules), parse_msg(msg)}
  end
end
