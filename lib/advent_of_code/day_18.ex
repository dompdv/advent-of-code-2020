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

  def part2(_args) do
  end
end
