defmodule AdventOfCode.Day07 do
  def part1(args) do
    rules = parse_input(args)
    (recursive_search(rules, ["shiny gold"], MapSet.new()) |> Enum.count()) - 1
  end

  def part2(args) do
    rules = parse_input(args) |> Map.new()
    recursive_count(rules, "shiny gold") - 1
  end

  defp recursive_count(rules, container) do
    1 +
    Enum.reduce(
      Map.get(rules, container),
      0,
      fn {bag, qty}, acc -> acc + qty * recursive_count(rules, bag) end)
  end

  defp recursive_search(_rules, [], found) do
    found
  end

  defp recursive_search(rules, [a_bag | rest], found) do
    new_bags = search(rules, a_bag, MapSet.union(found, MapSet.new(rest)))
    recursive_search(rules, rest ++ new_bags, MapSet.put(found, a_bag))
  end

  defp search(rules, a_bag, existing) do
    Enum.filter(rules, fn {_big_bag, bags} -> Map.has_key?(bags, a_bag) end)
    |> Enum.map(fn {big_bag, _bags} -> big_bag end)
    |> Enum.filter(fn bag -> not MapSet.member?(existing, bag) end)
  end

  defp parse_rule(rule) do
    [left, right] = String.split(rule, " contain ")
                    |> Enum.map(&String.replace(&1,"bags", ""))
                    |> Enum.map(&String.replace(&1,"bag", ""))
                    |> Enum.map(&String.trim(&1,"."))
                    |> Enum.map(&String.trim(&1))
    bag = if right == "no other" do
      %{}
    else
      String.split(right, ",")
              |> Enum.map(&String.trim(&1))
              |> Enum.map(fn stmt ->
                            [qty | rest] = String.split(stmt, " ")
                            qty = String.to_integer(qty)
                            bag = Enum.join(rest, " ")
                            {bag, qty}
                          end)
              |> Enum.into(%{})
    end
    {left, bag}
  end

  defp parse_input(args) do
    args
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&parse_rule/1)
  end
end
