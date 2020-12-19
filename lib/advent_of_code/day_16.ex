defmodule AdventOfCode.Day16 do
  def part1(args) do
    {_, input} = parse(args)

    Enum.flat_map(input.nearby, fn x->x end)
    |> Enum.filter( &(not valid_number?(&1, input.rules)))
    |> Enum.sum()
  end

  def part2(args) do
    {_, input} = parse(args)
    # Remove invalid tickets, if any
    cleaned_nearby = Enum.filter(input.nearby, fn ticket -> Enum.all?(ticket, &(valid_number?(&1, input.rules))) end)
    # The set of classes
    classes = Enum.map(input.rules, fn {class, _} -> class end) |> MapSet.new()
    # for each field (numbered from 0 to n-1), we have an associated set of possible class. We start with the fact that all classes are possible
    hypo = Enum.map(0..(Enum.count(input.ticket) -1), fn i -> {i, classes} end) |> Map.new()
    # going through each field of each nearby ticket, we are able to rule out some hypothesis
    sieved_fields = Enum.reduce(cleaned_nearby, hypo, fn ticket, h -> sieve(ticket, h, input.rules) end)
    # At the end, some field can unambiguously attached to a class, but this helps ruling out some classes for the other fields
    {_, solutions} = converge(sieved_fields, %{})


    # Fields starting by "departure" (putaing il doit y avoir une façon simple de faire mais j'ai la flemme de le faire, même si je vois comment)
    depart_field = Enum.filter(solutions, fn {_index, m} -> [class] = MapSet.to_list(m)
                                                            String.starts_with?(class, "departure")
                                          end)
                  |> Enum.map(fn {index, _} -> index end)
                  |> MapSet.new()
    Enum.with_index(input.ticket)
      |> Enum.filter(fn {_n, index} -> MapSet.member?(depart_field, index) end)
      |> Enum.map(&(elem(&1, 0)))
      |> Enum.reduce(1, fn x,acc -> acc * x end)
  end

  def converge(fields, mapping) do
    solved_field = Stream.drop_while(fields, fn {_index, m} -> MapSet.size(m) > 1 end) |> Enum.take(1)
    case solved_field do
      [] -> {fields, mapping}
      [{index, m}] -> new_mapping = Map.put(mapping, index, m)
                      new_fields = Enum.map(Map.to_list(Map.delete(fields, index)), fn {i, h} -> {i, MapSet.difference(h, m)} end) |> Map.new()
                      converge(new_fields, new_mapping)
    end
  end

  def valid_number?(number, rules) do
    Enum.any?(rules,
            fn {_, ranges} -> Enum.any?(ranges, fn {l, h} -> l <= number and number <= h end) end)
  end

  defp broken_rules(number, rules) do
    Enum.map(rules, fn {rule, ranges} -> {rule, Enum.any?(ranges, fn {l, h} -> l <= number and number <= h end)} end)
    |> Enum.filter(fn {_, t}-> not t end)
    |> Enum.map(&(elem(&1, 0)))
    |> MapSet.new()
  end

  defp sieve(a_ticket, hypo, rules) do
    Enum.with_index(a_ticket)
    |> Enum.reduce(hypo,
      fn {number, index}, h ->
        b_rules = broken_rules(number, rules)
        hypo_field = Map.get(h, index)
        Map.put(h, index, MapSet.difference(hypo_field, b_rules))
      end)
  end

  defp parse(input) do
    input
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    |> Enum.reduce({:rules, %{rules: [], ticket: [], nearby: []}}, &parse_line/2)
  end

  defp parse_line(line, {:rules, acc}) do
    cond do
      line == "your ticket:" -> {:ticket, acc}
      line == "nearby tickets:" -> {:nearby, acc}
      true -> [class, rest] = String.split(line, ":")
              ranges = String.split(String.trim(rest), "or") |> Enum.map(&String.trim/1)
                      |> Enum.map(fn s -> [l, h] = String.split(s, "-")
                                          {String.to_integer(l) , String.to_integer(h)} end)
              {:rules, %{acc | rules: [{class, ranges} | acc.rules]}}
    end
  end
  defp parse_line(line, {:ticket, acc}) do
    cond do
      line == "nearby tickets:" -> {:nearby, acc}
      true -> fields = String.split(line, ",") |> Enum.map(&String.to_integer/1)
              {:ticket, %{acc | ticket: fields}}
    end
  end
  defp parse_line(line, {:nearby, acc}) do
    fields = String.split(line, ",") |> Enum.map(&String.to_integer/1)
    {:nearby, %{acc | nearby: [fields | acc.nearby]}}
  end
end
