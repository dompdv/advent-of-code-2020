defmodule AdventOfCode.Day19 do

  import Enum


  def part2(args) do
    process(args, &alter_rules_part2/1)
  end

  def process(args, alter_rules_fun) do
    {rules, lines} = parse_args(args) |> alter_rules_fun.()

    lines
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&parse(&1, ["0"], rules))
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def alter_rules_part2({rules, lines}) do
    {build_rules(["8: 42 | 42 8", "11: 42 31 | 42 11 31"], rules), lines}
  end

  def parse_args(args) do
    [rule_defs, lines] = String.split(args, "\n\n", trim: true)

    {
      build_rules(String.split(rule_defs, "\n", trim: true), Map.new()),
      String.split(lines, "\n", trim: true)
    }
  end

  def build_rules([rule_def | rest], rules) do
    [id, rule_expr] = String.split(rule_def, ": ", trim: true)
    rule = build_specific_rule(rule_expr)
    build_rules(rest, Map.put(rules, id, rule))
  end

  def build_rules([], rules) do
    rules
  end

  def build_specific_rule(rule_expr) when binary_part(rule_expr, 0, 1) == "\"" do
    {:char, String.graphemes(rule_expr) |> Enum.at(1)}
  end

  def build_specific_rule(rule_expr) do
    String.split(rule_expr, "|", trim: true)
    |> Enum.map(fn subrule ->
      String.split(subrule, " ", trim: true)
    end)
  end

  def parse([char | rest] = str, [stack_rule_id | rest_stacked_rules_id], rules) do
    case Map.get(rules, stack_rule_id, nil) do
      {:char, rule_char} ->
        if rule_char == char do
          parse(rest, rest_stacked_rules_id, rules)
        else
          false
        end

      subrules ->
        Enum.any?(subrules, fn subrule ->
          parse(str, subrule ++ rest_stacked_rules_id, rules)
        end)
    end
  end

  def parse([], [], _), do: true

  def parse(_, _, _), do: false




  def part1(args) do
    {rules, msgs} = parse(args)
    process(rules, msgs, &Function.identity/1)
  end

  def part2_i(args) do
    {rules, msgs} = parse(args)

    process(rules, msgs, fn rules ->
      rules
      |> Map.put("8", {:alt, ["42"], ["42", "8"]})
      |> Map.put("11", {:alt, ["42", "31"], ["42", "11", "31"]})
    end)
  end

  def process(rules, msgs, alter_func) do
    rules = alter_func.(rules)
    msgs
    |> map(fn msg -> check_rules(msg, rules["0"], rules) end)
    |> filter(fn {t, s} -> t and s == "" end)
    |> count()
  end

  def check_rules(msg, {:str, s}, _rules) do
    if String.first(msg) == s, do: {true, String.slice(msg, 1..-1)}, else: {false, msg}
  end

  def check_rules(msg, {:subrules, [h]}, rules) do
    check_rules(msg, rules[h], rules)
  end

  def check_rules(msg, {:subrules, [h | r]}, rules) do
    {checked, remainder} = check_rules(msg, rules[h], rules)
    if checked, do: check_rules(remainder, {:subrules, r}, rules), else: {false, msg}
  end

  def check_rules(msg, {:alt, left, right}, rules) do
    {check_left, m_left} = check_rules(msg, {:subrules, left}, rules)
    if check_left do
      {true, m_left}
    else
      {check_right, m_right} = check_rules(msg, {:subrules, right}, rules)
      if check_right, do: {true, m_right}, else: {false, msg}
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

  def parse_rules(rules) do
    rules
    |> String.split("\n", trim: true)
    |> map(fn x ->
      [rule_number, r] = String.split(x, ": ", trim: true)
      parse_rule(String.trim(rule_number), String.trim(r))
    end)
    |> Map.new()
  end

  def parse(input) do
    [rules, msg] = String.split(input, "\n\n", trim: true)
    {parse_rules(rules), msg |> String.split("\n", trim: true)}
  end
end
