defmodule Day8Test do
  use ExUnit.Case
  doctest Day8

  test "day 8 line of sight" do
    arr = [
      [3, 0, 3, 7, 3],
      [2, 5, 5, 1, 2],
      [6, 5, 3, 3, 2],
      [3, 3, 5, 4, 9],
      [3, 5, 3, 9, 0]
    ] |> Day8.Array2D.new()

    assert Day8.scenic_score(arr, 1, 2) == 4
  end
end
