defmodule AdventOfCode.Day14 do
  use Bitwise
  def part1(args) do
    {mem, _, _} =
      parse(args) |> Enum.map(&parse_mask/1)
      |> Enum.reduce({%{}, 0, 0}, &execute/2)
    Enum.sum(Map.values(mem))
  end

  def execute({:mask, zero, one}, {mem, _, _}) do
    {mem, zero, one}
  end

  def execute({:ld, where, what}, {mem, zero, one}) do
    {Map.put(mem, where, (what &&& zero)|||one), zero, one}
  end

  def part2(_args) do
  end

  def parse_mask({:ld, _, _} = line), do: line
  def parse_mask({:mask, mask}) do
    {_, zero, one} =
      String.graphemes(mask)
      |> Enum.reverse()
      |> Enum.reduce(
        {1, 0, 0},
        fn x, {p, zero, one} ->
          case x do
            "X" -> {2 * p, zero + p, one}
            "0" -> {2 * p, zero, one}
            "1" -> {2 * p, zero + p, one + p}
          end
        end)
    {:mask, zero, one}
  end


  defp parse(input) do
    input
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    |> Enum.map(
      fn line ->
       cond do
        Regex.match?(~r/mask = [X|0|1]+/, line) ->
                                [mask] = Regex.run(~r/[X|0|1]+/, line)
                                {:mask, mask}
          Regex.match?(~r/mem\[(\d+)\] = (\d+)/, line) ->
                                [_, cell, value] = Regex.run(~r/mem\[(\d+)\] = (\d+)/, line)
                                {:ld, String.to_integer(cell), String.to_integer(value)}
        true -> line
       end
    end)
  end

end
