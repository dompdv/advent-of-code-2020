defmodule AdventOfCode.Day19 do
  def part1(args) do
    {rules, msgs} = parse(args)

    msgs
    |> Enum.map(fn msg -> check_rules(msg, rules[0], rules) end)
    |> Enum.map(fn {t, s} -> t and s == "" end)
    |> Enum.filter(fn t -> t end)
    |> Enum.count()
  end

  def part2(args) do
    {rules, msgs} = parse(args)
    IO.inspect(rules[8])
    IO.inspect(rules[11])

    rules =
      rules |> Map.put(8, {:alt, [42], [42, 8]}) |> Map.put(11, {:alt, [42, 31], [42, 11, 31]})

    IO.inspect(rules[8])
    IO.inspect(rules[11])
    msgs |> Enum.map(fn msg -> check_rules(msg, rules[0], rules) end)
    #    |> Enum.map(fn {t, s} -> t and s == "" end)
    #    |> Enum.filter(fn t -> t end)
    #    |> Enum.count()
  end

  def check_rules(msg, rule, rules) do
    # IO.inspect({msg, rule})
    case rule do
      {:str, s} ->
        l = String.length(s)

        if String.slice(msg, 0..(l - 1)) == s do
          {true, String.slice(msg, l..-1)}
        else
          {false, msg}
        end

      {:rule, []} ->
        {true, msg}

      {:rule, [h | r]} ->
        {checked, remainder} = check_rules(msg, rules[h], rules)

        if checked do
          check_rules(remainder, {:rule, r}, rules)
        else
          {false, msg}
        end

      {:alt, left, right} ->
        {check_left, m_left} = check_rules(msg, {:rule, left}, rules)
        {check_right, m_right} = check_rules(msg, {:rule, right}, rules)

        cond do
          check_left -> {true, m_left}
          check_right -> {true, m_right}
          true -> {false, msg}
        end
    end
  end

  defp to_list(s) do
    s |> String.split(" ", trim: true) |> Enum.map(fn x -> String.to_integer(String.trim(x)) end)
  end

  @spec parse_rules(binary) :: map
  def parse_rules(rules) do
    rules
    |> String.split("\n")
    |> Enum.map(fn x -> x |> String.trim() |> String.split(":") end)
    |> Enum.map(fn [rule_number, r] -> {String.to_integer(rule_number), String.trim(r)} end)
    |> Enum.map(fn {rule_number, r} ->
      cond do
        String.contains?(r, ~s(")) ->
          [_, msg, _] = String.split(r, ~s("))
          {rule_number, {:str, msg}}

        String.contains?(r, "|") ->
          [left, right] = String.split(r, "|")
          {rule_number, {:alt, to_list(left), to_list(right)}}

        true ->
          {rule_number, {:rule, to_list(r)}}
      end
    end)
    |> Map.new()
  end

  def parse_msg(rules) do
    rules |> String.split("\n") |> Enum.map(&String.trim/1) |> Enum.filter(fn x -> x != "" end)
  end

  def parse(input) do
    [rules, msg] = String.split(input, "\n\n")
    {parse_rules(rules), parse_msg(msg)}
  end
end
