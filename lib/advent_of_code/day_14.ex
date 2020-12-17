defmodule AdventOfCode.Day14 do
  use Bitwise
# ----------------------------------------------------------
# Part 1
# ----------------------------------------------------------
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

# ----------------------------------------------------------
# Part 2
# ----------------------------------------------------------

  def part2(args) do
    {mem, _, _, _} =
      parse(args) |> Enum.map(&parse_mask2/1)
      |> Enum.reduce({%{}, 0, 0, []}, &execute2/2)
    Enum.sum(Map.values(mem))
  end

  def execute2({:mask, zero, one, floating}, {mem, _, _, _}) do
    {mem, zero, one, floating}
  end


  def execute2({:ld, where, what}, {mem, zero, one, floating}) do
    altered_where = (where &&& zero) ||| one
    new_mem =
      Enum.reduce(
        0..((1 <<< Enum.count(floating)) - 1),
        mem,
        fn n, mem_state -> Map.put(mem_state, altered_where ||| memory_mask(n, floating), what)
      end
      )
    {new_mem, zero, one, floating}
  end

  def to_binary_list(n), do: to_binary_list(n, [])
  def to_binary_list(1, list), do: [1|list]
  def to_binary_list(0, list), do: [0|list]
  def to_binary_list(n, list), do: to_binary_list(div(n, 2), [rem(n,2) | list])

  def memory_mask(n, powers) do
    Enum.zip(Enum.reverse(to_binary_list(n)), powers)
      |> Enum.map(fn {a, b} -> a * b end)
      |> Enum.sum()
  end

  def parse_mask2({:ld, _, _} = line), do: line
  def parse_mask2({:mask, mask}) do
    {_, _, zero, one, floating} =
      String.graphemes(mask)
      |> Enum.reverse()
      |> Enum.reduce(
        {0, 1, 0, 0, []},
        fn x, {i, p, zero, one, floating} ->
          case x do
            "X" -> {i + 1, 2 * p, zero, one, [1 <<< i | floating]}
            "0" -> {i + 1, 2 * p, zero + p, one, floating}
            "1" -> {i + 1, 2 * p, zero, one + p, floating}
          end
        end)
    {:mask, zero, one, Enum.reverse(floating)}
  end

# ----------------------------------------------------------
# Common
# ----------------------------------------------------------

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
