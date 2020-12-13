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

  def part2(_args) do
  end

  defp parse(input) do
    # acquire and clean
    input |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    # parse each line
    |> Enum.map(fn s -> {String.at(s, 0) , String.slice(s, 1..-1) |> String.to_integer} end) |> IO.inspect()
  end
end
