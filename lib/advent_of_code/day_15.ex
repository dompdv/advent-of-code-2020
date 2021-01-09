defmodule AdventOfCode.Day15 do
  def part1(args) do
    play(args, 2020)
  end

  def part2(args) do
    play(args, 30_000_000)
  end

  def play(args, turns) do
    # Process the starting sequence
    starting_len = Enum.count(args)
    starting = Enum.zip(1..starting_len, args)
    state_after_starting = Enum.reduce(starting, {0, %{}}, &update_starting/2)

    # Play
    {last, _} = Enum.reduce((starting_len + 1)..turns, state_after_starting, &play_turn/2)
    last
  end

  def update_starting({turn, number}, {_last, log}) do
    {number, Map.put(log, number, {turn, 0})}
  end

  def update_log(turn, number, log) do
    if Map.has_key?(log, number) do
      {last, _first} = Map.get(log, number)
      Map.put(log, number, {turn, last})
    else
      Map.put(log, number, {turn, 0})
    end
  end

  def play_turn(turn, {last, log}) do
    if Map.has_key?(log, last) do
      {last, first} = Map.get(log, last)
      outcome = if first > 0, do: last - first, else: 0
      {outcome, update_log(turn, outcome, log)}
    else
      {0, update_log(turn, 0, log)}
    end
  end
end
