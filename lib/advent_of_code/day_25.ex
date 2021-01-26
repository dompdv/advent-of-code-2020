defmodule AdventOfCode.Day25 do
  def part1(args) do
    {card_pk, door_pk} = args
    {card_loop_size, door_loop_size} = {loop_until(7, card_pk), loop_until(7, door_pk)}
    {loop(door_pk, card_loop_size), loop(card_pk, door_loop_size)}
  end

  def loop_until(subject, target) do
    Stream.iterate({0, 1}, fn {n, acc} -> {n + 1, rem(subject * acc, 20_201_227)} end)
    |> Stream.drop_while(fn {_, x} -> x != target end)
    |> Enum.take(1)
    |> hd()
    |> elem(0)
  end

  def loop(subject, loop_size) do
    Enum.reduce(1..loop_size, 1, fn _, acc -> rem(subject * acc, 20_201_227) end)
  end

  def part2(_args) do
    "done"
  end
end
