defmodule Mix.Tasks.D25.P1 do
  use Mix.Task

  import AdventOfCode.Day25

  @shortdoc "Day 25 Part 1"
  def run(args) do
    input = {5_764_801, 17_807_724}
    input = {2_069_194, 16_426_071}

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
