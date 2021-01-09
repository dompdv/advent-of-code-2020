defmodule Mix.Tasks.D19.P1 do
  use Mix.Task

  import AdventOfCode.Day19

  @shortdoc "Day 19 Part 1"
  def run(args) do
    input = ~s(0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb)
    input = AdventOfCode.Input.get!(19, 2020)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
