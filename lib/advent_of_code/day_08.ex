defmodule AdventOfCode.Day08 do
  def part1(args) do
    program = parse(args)
    Stream.iterate(load(program), &execute/1)
    |> Stream.drop_while(&running?/1)
    |> Enum.take(1)
    |> Enum.at(0)
    |> acc()
  end

  def part2(_args) do
  end

  defp load(program) do
    %{program: program, pc: 0, visited: MapSet.new(), acc: 0, running: true}
  end

  def running?(%{running: running}) do
    running
  end

  defp acc(%{acc: acc}) do
    acc
  end

  defp execute(%{program: program, pc: pc, visited: visited, acc: acc, running: running}) do
    if not running do
      %{program: program, pc: pc, visited: visited, acc: acc, running: false}
    else
        if MapSet.member?(visited, pc) do
          %{program: program, pc: pc, visited: visited, acc: acc, running: false}
        else
          {op, par} = Enum.at(program, pc)
          case op do
            :nop -> %{program: program, pc: pc + 1, visited: MapSet.put(visited, pc), acc: acc, running: true}
            :acc -> %{program: program, pc: pc + 1, visited: MapSet.put(visited, pc), acc: acc + par, running: true}
            :jmp -> %{program: program, pc: pc + par, visited: MapSet.put(visited, pc), acc: acc , running: true}
          end
        end
    end
  end

  defp parse_line(line) do
    [cmd, parameter] = line |> String.split(" ")
    { case cmd do
      "nop" -> :nop
      "acc" -> :acc
      "jmp" -> :jmp
    end,
      String.to_integer(parameter)
    }
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&parse_line/1)
  end
end
