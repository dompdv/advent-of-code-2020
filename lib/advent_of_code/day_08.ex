defmodule AdventOfCode.Day08 do
  def part1(args) do
    program = parse(args)
    run(program) |> acc()
  end

  def part2(args) do
    program = parse(args)
    possible_changes(0, program, [])
    |> Enum.map(fn change -> tweak_program(program, change) end)
    |> Stream.map(&run/1)
    |> Stream.drop_while(&looping?/1)
    |> Enum.take(1) |> Enum.at(0) |> acc()
  end

  defp tweak_program(program, {line, new_command}) do
    Enum.with_index(program)
    |> Enum.map(
      fn {command, l} ->
        if l == line, do: new_command, else: command
      end)
  end

  defp possible_changes(_line, [], change_list), do: change_list

  defp possible_changes(line, [{op, par} | program], change_list) do
    case op do
      :nop -> possible_changes(line + 1, program, [{line, {:jmp, par}} | change_list])
      :acc -> possible_changes(line + 1, program, change_list)
      :jmp -> possible_changes(line + 1, program, [{line, {:nop, par}} | change_list])
    end
  end

  defp load(program) do
    %{program: program, pc: 0, visited: MapSet.new(), acc: 0, running: true, looping: false, len: Enum.count(program)}
  end

  defp run(program) do
    Stream.iterate(load(program), &execute/1)
    |> Stream.drop_while(&running?/1)
    |> Enum.take(1) |> Enum.at(0)
  end

  def running?(%{running: running}), do: running
  def looping?(%{looping: looping}), do: looping
  defp acc(%{acc: acc}), do: acc

  defp execute(%{program: program, pc: pc, visited: visited, acc: acc, running: running, len: length} = computer) do
    cond do
      not running -> computer
      MapSet.member?(visited, pc) -> %{computer | running: false, looping: true}
      pc >= length -> %{computer | running: false, looping: false}
      true -> {op, par} = Enum.at(program, pc)
              case op do
                :nop -> %{computer | pc: pc + 1, visited: MapSet.put(visited, pc)}
                :acc -> %{computer | pc: pc + 1, visited: MapSet.put(visited, pc), acc: acc + par}
                :jmp -> %{computer | pc: pc + par, visited: MapSet.put(visited, pc)}
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
