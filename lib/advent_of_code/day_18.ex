defmodule AdventOfCode.Day18 do
  def part1(args) do
    args
    |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    |> Enum.map(&evaluate_a_line/1)
    |> Enum.sum()
  end

  def evaluate_a_line(args) do
    {_, tokens,_} = Enum.reduce(String.graphemes(args) ++ [" "], {[], [], :starting}, &tokenize/2)
    evaluate(Enum.reverse(tokens))
  end

  defp evaluate([]) do
    0
  end
  defp evaluate([{:num, op1}]) do
    op1
  end
  defp evaluate([{:num, op1}, :plus | rest]) do
    op1 + evaluate(rest)
  end

  defp evaluate([{:num, op1}, :mul | rest]) do
    op1 * evaluate(rest)
  end

  defp evaluate([:cl | rest]) do
    {in_par, after_par} = matching_par(rest, 0, [])
    case after_par do
      [] -> evaluate(in_par)
      [:plus |rest3] -> evaluate(in_par) + evaluate(rest3)
      [:mul  |rest3] -> evaluate(in_par) * evaluate(rest3)
    end
  end

  defp matching_par([], 0, acc), do: {acc, []}
  defp matching_par([:cl|rest], level, acc), do: matching_par(rest, level + 1, acc ++ [:cl])
  defp matching_par([:op|rest], 0, acc), do: {acc, rest}
  defp matching_par([:op|rest], level, acc), do: matching_par(rest, level - 1, acc ++ [:op])
  defp matching_par([h|rest], level, acc), do: matching_par(rest, level, acc ++ [h])


  def numeric?(char) do
    Regex.match?(~r/^\d+$/, char)
  end

  defp tokenize(c, {[], tokens, :starting}) do
    cond do
      c == " " -> {[], tokens, :starting}
      c == "+" -> {[], tokens ++ [:plus], :starting}
      c == "*" -> {[], tokens ++ [:mul], :starting}
      c == "(" -> {[], tokens ++ [:op], :starting}
      c == ")" -> {[], tokens++ [:cl], :starting}
      numeric?(c) -> {c, tokens, :numeric}
    end
  end

  defp tokenize(c, {acc, tokens, :numeric}) do
    cond do
      c in [" ", "+", "*", "(", ")"] -> tokenize(c, {[], tokens ++ [{:num, String.to_integer(acc)}], :starting})
      numeric?(c) -> {~s(#{acc}#{c}), tokens, :numeric}
    end
  end

  def part2(args) do
    input = args |> String.split("\n") |> Enum.filter(&(&1 != "")) |> Enum.map(&String.trim/1)
    results = input |> Enum.map(&evaluate_a_line2/1)
    # Enum.zip(input, results) |> Enum.map(&IO.inspect/1)
    results |> Enum.sum()
  end

  def evaluate_a_line2(args) do
     {_, tokens,_} = Enum.reduce(String.graphemes(args) ++ [" "], {[], [], :starting}, &tokenize/2)
     reduce_expr(tokens)
  end

  def reduce_expr([]), do: :err
  def reduce_expr([{:num, op}]), do: op

  def reduce_expr(expr) do
    {expr, modified1} = reduce_plus(expr, [], false)
    {expr, modified2} = reduce_par(expr, [], false)
    if modified1 or modified2 do
      reduce_expr(expr)
    else
      is_plus = Enum.any?(expr, fn token -> token == :plus end)
      {expr, modified} = reduce_mul(expr, [], false, is_plus)
      if modified, do: reduce_expr(expr), else: expr
    end
  end
  def reduce_plus([], acc, modified), do: {Enum.reverse(acc), modified}
  def reduce_plus([{:num, op1}, :plus, {:num, op2}|rest], acc, _) do
    reduce_plus([{:num, op1 + op2} | rest], acc, true)
  end
  def reduce_plus([h|rest], acc, modified) do
    reduce_plus(rest, [h|acc], modified)
  end

  def reduce_par([], acc, modified), do: {Enum.reverse(acc), modified}
  def reduce_par([:op, {:num, op}, :cl|rest], acc, _) do
    reduce_par([{:num, op} | rest], acc, true)
  end
  def reduce_par([h|rest], acc, modified) do
    reduce_par(rest, [h|acc], modified)
  end

  def reduce_mul([], acc, modified, _), do: {Enum.reverse(acc), modified}

  def reduce_mul([:mul, {:num, op1}, :mul, {:num, op2}, :mul|rest], acc, _, is_plus) do
    reduce_mul([:mul, {:num, op1 * op2}, :mul | rest], acc, true, is_plus)
  end
  def reduce_mul([:op, {:num, op1}, :mul, {:num, op2}, :mul|rest], acc, _, is_plus) do
    reduce_mul([:op, {:num, op1 * op2}, :mul | rest], acc, true, is_plus)
  end


  def reduce_mul([:op, {:num, op1}, :mul, {:num, op2}, :cl|rest], acc, _, is_plus) do
    reduce_mul([{:num, op1 * op2} | rest], acc, true, is_plus)
  end

  def reduce_mul([{:num, op1}, :mul, {:num, op2}], acc, _, false) do
    reduce_mul([{:num, op1 * op2}], acc, true, false)
  end

  def reduce_mul([h|rest], acc, modified, is_plus) do
    reduce_mul(rest, [h|acc], modified, is_plus)
  end

end
