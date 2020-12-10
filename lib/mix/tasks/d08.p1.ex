defmodule Mix.Tasks.D08.P1 do
  use Mix.Task

  import AdventOfCode.Day08

  @shortdoc "Day 08 Part 1"
  def run(args) do
    input = "nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6"
input = AdventOfCode.Input.get!(8, 2020)
    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
