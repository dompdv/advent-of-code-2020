defmodule AdventOfCode.Day09 do
  def part1(args) do
    {preamble, rest} = split_preamble(parse(args), 25)
    scan_until_failure(preamble, rest)
  end

  def part2(args) do
    input = parse(args)
    len = Enum.count(input)
    Enum.reduce_while(2..len, 0, fn window_size, _ -> test_window(len, input, window_size, 373803594) end)
  end

  defp test_window(len, input, window_size, target) do
    case Enum.reduce_while(0..(len - window_size), 0,
      fn start, _ ->
        if Enum.sum(Enum.slice(input, start..(start + window_size - 1))) == target do
          {:halt, {:found, Enum.slice(input, start..(start + window_size - 1))}}
        else
          {:cont, :not_found}
        end
      end) do
        {:found, list} -> IO.inspect(list)
                          {:halt, {:found, Enum.min(list) + Enum.max(list)}}
        _ -> {:cont, :not_found}
      end
  end

  defp scan_until_failure(_, []) do
    :ok
  end

  defp scan_until_failure([_ | tp] = preamble, [target | tail]) do
    sorted_preamble = Enum.sort(preamble)
    case narrow(sorted_preamble, target) do
      :not_found -> target
      :ok -> scan_until_failure(tp ++ [target], tail)
    end
  end

  defp narrow([], _target) do
    :not_found
  end

  defp narrow(expenses, target) do
    f = List.first(expenses)
    l = List.last(expenses)
    t =  f + l
    cond do
      t == target -> :ok
      t < target -> narrow(Enum.slice(expenses, 1..-1), target)
      true -> narrow(Enum.slice(expenses, 0..-2), target)
    end
  end


  defp split_preamble(a_list, p) do
    preamble = Enum.slice(a_list, 0..(p - 1))
    remaining = Enum.slice(a_list, p..-1)
    {preamble, remaining}
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(fn s -> String.trim(s) |> String.to_integer() end)
  end
end
