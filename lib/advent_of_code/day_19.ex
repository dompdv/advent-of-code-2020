defmodule AdventOfCode.Day19 do
  def part1(args) do
    {rules, msgs} = parse(args)
    process(rules, msgs, &Function.identity/1)
  end

  def part2(args) do
    {rules, msgs} = parse(args)
    process(rules, msgs, fn rules ->
      rules |> Map.put(8, {:alt, [42], [42, 8]}) |> Map.put(11, {:alt, [42, 31], [42, 11, 31]})
    end)
  end

  def process(rules, msgs, alter_func) do
    rules = alter_func.(rules)
    msgs
    |> Enum.map(fn msg -> check_rules(msg, rules["0"], rules) end)
    |> Enum.filter(fn {t, s} -> t and s == "" end)
    |> Enum.count()
  end

  def check_rules(msg, {:str, s}, _rules) do
    if String.first(msg) == s, do: {true, String.slice(msg, 1..-1)}, else: {false, msg}
  end

  def check_rules(msg, {:subrules, []}, _rules), do: {true, msg}

  def check_rules(msg, {:subrules, [h | r]}, rules) do
    {checked, remainder} = check_rules(msg, rules[h], rules)
    if checked, do: check_rules(remainder, {:subrules, r}, rules), else: {false, msg}
  end

  def check_rules(msg, {:alt, left, right}, rules) do
    {check_left, m_left} = check_rules(msg, {:subrules, left}, rules)
    {check_right, m_right} = check_rules(msg, {:subrules, right}, rules)

    cond do
      check_left -> {true, m_left}
      check_right -> {true, m_right}
      true -> {false, msg}
    end
  end

  def parse_rule(rule_number, r) do
    cond do
      String.contains?(r, ~s(")) ->
        [_, msg, _] = String.split(r, ~s("))
        {rule_number, {:str, msg}}

      String.contains?(r, "|") ->
        [left, right] = String.split(r, "|")

        {rule_number,
         {:alt, left |> String.split(" ", trim: true), right |> String.split(" ", trim: true)}}

      true ->
        {rule_number, {:subrules, r |> String.split(" ", trim: true)}}
    end
  end

  @spec parse_rules(binary) :: map
  def parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> Enum.map(fn x ->
      [rule_number, r] = String.split(x, ": ", trim: true)
      parse_rule(String.trim(rule_number) , String.trim(r))
    end)
    |> Map.new()
  end

  def parse(input) do
    [rules, msg] = String.split(input, "\n\n", trim: true)
    {parse_rules(rules), msg |> String.split("\n", trim: true)}
  end
end
