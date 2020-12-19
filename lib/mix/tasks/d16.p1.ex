defmodule Mix.Tasks.D16.P1 do
  use Mix.Task

  import AdventOfCode.Day16

  @shortdoc "Day 16 Part 1"
  def run(args) do
    _input = AdventOfCode.Input.get!(16, 2020)
    input = "class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12"

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
