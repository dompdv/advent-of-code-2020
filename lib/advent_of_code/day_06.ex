defmodule AdventOfCode.Day06 do
  def part1(args) do
    parse_input(args)
    |> Enum.map(&concat_deduplicate_count/1)
    |> Enum.sum()
  end

  def part2(args) do
    parse_input(args)
    |> Enum.map(&intersect_count/1)
    |> Enum.sum()
  end

  defp concat_deduplicate_count(string_list) do
    string_list
    |> List.foldl([], fn x, acc -> String.graphemes(x) ++ acc end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp intersect_count(string_list) do
    string_list
    # convert String to List
    |> Enum.map(&String.graphemes/1)
    # Convert List to MapSet
    |> Enum.map(&MapSet.new/1)
    # Intersect all MapSet into one
    |> Enum.reduce(fn x, acc -> MapSet.intersection(x, acc) end)
    |> Enum.count()
  end

  defp parse_input(args) do
    String.split(args, "\n")
    |> Enum.chunk_by(fn line -> line == "" end)
    |> Enum.filter(fn line -> line != [""] end)
  end
end
