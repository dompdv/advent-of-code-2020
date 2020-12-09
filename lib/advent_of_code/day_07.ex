defmodule AdventOfCode.Day07 do
  def part1(args) do
    rules = parse_input(args)
    #IO.inspect(rules)
    (recursive_search(rules, ["shiny gold"], []) |> Enum.count()) - 1
  end

  def part2(_args) do
  end


  defp recursive_search(_rules, [], found) do
    found
  end

  defp recursive_search(rules, [a_bag | rest], found) do
    new_bags = search(rules, a_bag, found ++ rest)
    recursive_search(rules, rest ++ new_bags, [a_bag |found])
  end

  defp search(rules, a_bag, existing) do
    found = Enum.filter(rules, fn {_big_bag, bags} -> Map.has_key?(bags, a_bag) end)
    |> Enum.map(fn {big_bag, _bags} -> big_bag end)
    |> MapSet.new()
    MapSet.difference(found, MapSet.new(existing))
    |> MapSet.to_list()
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
