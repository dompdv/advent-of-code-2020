defmodule Mix.Tasks.D22.P2 do
  use Mix.Task

  import AdventOfCode.Day22

  @shortdoc "Day 22 Part 2"
  def run(args) do
    input = "Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10"
    input = AdventOfCode.Input.get!(22, 2020)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
