defmodule AdventOfCode.Day12 do

  @directions %{"N" => {0, 1}, "E" => {1, 0}, "S" => {0, -1}, "W" => {-1, 0}}
  @cycle %{0 => "E", 1 => "N", 2 => "W", 3 => "S"}

  def part1(args) do
    %{x: x, y: y} = Enum.reduce(parse(args), %{dir: 0, x: 0, y: 0}, &move/2)
    abs(x) + abs(y)
  end

  def move({cmd, par}, %{dir: dir, x: x, y: y} = state) do
    {vx, vy} = @directions[@cycle[dir]]
    cond do
      cmd == "F" -> %{state | x: x + par * vx, y: y + par * vy}
      cmd == "R" -> %{state | dir: rem(12 + dir - div(par, 90), 4)}
      cmd == "L" -> %{state | dir: rem(dir + div(par, 90), 4)}
      true -> {vx, vy} = @directions[cmd]
              %{state | x: x + par * vx, y: y + par * vy}
    end
  end

  def part2(args) do
    %{x: x, y: y} = Enum.reduce(parse(args), %{x: 0, y: 0, dx: 10, dy: 1}, &move2/2)
    abs(x) + abs(y)
  end

  def move2({cmd, par}, %{x: x, y: y, dx: dx, dy: dy} = state) do
    cond do
      cmd == "F" -> %{state | x: x + par * dx, y: y + par * dy}
      cmd == "R" -> case par do
                      0 -> state
                      90 -> %{state | dx: dy, dy: -dx}
                      180 -> %{state | dx: -dx, dy: -dy}
                      270 -> %{state | dx: -dy, dy: dx}
                    end
      cmd == "L" -> case par do
                    0 -> state
                    90 -> %{state | dx: -dy, dy: dx}
                    180 -> %{state | dx: -dx, dy: -dy}
                    270 -> %{state | dx: dy, dy: -dx}
                  end
      true -> {vx, vy} = @directions[cmd]
              %{state | dx: dx + par * vx, dy: dy + par * vy}
    end
  end

  defp parse(input) do
    # acquire and clean
    input |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    # parse each line
    |> Enum.map(fn s -> {String.at(s, 0) , String.slice(s, 1..-1) |> String.to_integer} end)
  end
end
