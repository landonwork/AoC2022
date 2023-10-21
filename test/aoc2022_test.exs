defmodule Aoc2022Test do
  use ExUnit.Case
  doctest Aoc2022

  test "day 8 line of sight" do
    arr = [
      [3, 0, 3, 7, 3],
      [2, 5, 5, 1, 2],
      [6, 5, 3, 3, 2],
      [3, 3, 5, 4, 9],
      [3, 5, 3, 9, 0]
    ] |> Arrays.new()

    assert Aoc2022.Day8.scenic_score(arr, 1, 2) == 4
  end
end
