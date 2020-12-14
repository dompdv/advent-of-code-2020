defmodule Mix.Tasks.D13.P2 do
  use Mix.Task

  import AdventOfCode.Day13

  @shortdoc "Day 13 Part 2"
  def run(args) do
    input = "939
    17,x,13,19"
    input = "939
    7,13,x,x,59,x,31,19"
    input = "939
    1789,37,47,1889"
    input = AdventOfCode.Input.get!(13, 2020)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
