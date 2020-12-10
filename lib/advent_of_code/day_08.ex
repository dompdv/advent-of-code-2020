defmodule AdventOfCode.Day08 do
  def part1(args) do
    program = parse(args)
    run(load(program)) |> acc()
  end

  def part2(args) do
    program = parse(args)

  end

  defp load(program) do
    %{program: program, pc: 0, visited: MapSet.new(), acc: 0, running: true, looping: false, len: Enum.count(program)}
  end

  defp run(computer) do
    Stream.iterate(computer, &execute/1)
    |> Stream.drop_while(&running?/1)
    |> Enum.take(1)
    |> Enum.at(0)
  end

  def running?(%{running: running}) do
    running
  end

  def looping?(%{looping: looping}) do
    looping
  end

  defp acc(%{acc: acc}) do
    acc
  end

  defp execute(%{program: program, pc: pc, visited: visited, acc: acc, running: running, looping: looping, len: length} = computer) do
    if not running do
      %{computer | running: false}
    else
        if MapSet.member?(visited, pc) do
          %{computer | running: false, looping: true}
        else
          if pc >= length do
            %{computer | running: false, looping: false}
          else
            {op, par} = Enum.at(program, pc)
            case op do
              :nop -> %{computer | pc: pc + 1, visited: MapSet.put(visited, pc)}
              :acc -> %{computer | pc: pc + 1, visited: MapSet.put(visited, pc), acc: acc + par}
              :jmp -> %{computer | pc: pc + par, visited: MapSet.put(visited, pc)}
            end
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
