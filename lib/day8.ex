
defmodule Day8 do
  defmodule Array2D do
    def new(list) do
      list
        |> Enum.map(&Enum.into(&1, Arrays.new()))
        |> Enum.into(Arrays.new())
    end

    @doc "LOL. This only works for square matrices"
    def transpose(arr) do
      new = arr
      row_max = Arrays.size(arr) - 1
      col_max = Arrays.size(arr[0]) - 1
      coords = (for row <- 0..row_max, col <- 0..col_max, do: {row, col})
      Enum.reduce(coords, new, fn({row, col}, acc) ->
        Arrays.replace(
          acc, 
          row,
            Arrays.replace(
              acc[row],
              col,
              arr[col][row]
            )
        ) end
      )
    end

    def slice(arr, row, range) when is_integer(row),
      do: (for i <- range, do: arr[row][i])

    def slice(arr, range, col) when is_integer(col),
      do: (for i <- range, do: arr[i][col])
  end

  def look_from(arr, direction)
  def look_from(arr, :left) do
    max_row = Arrays.size(arr) - 1
    max_col = Arrays.size(arr[0]) - 1
    for row <- 0..max_row do
      visible_trees(
        (for col <- 0..max_col, do: {row, col}),
        arr
      )
    end
      |> Array2D.new()
  end

  def look_from(arr, :right) do
    max_row = Arrays.size(arr) - 1
    max_col = Arrays.size(arr[0]) - 1
    for row <- 0..max_row do
      visible_trees(
        (for col <- max_col..0//-1, do: {row, col}),
        arr
      )
      |> Enum.reverse()
    end
      |> Array2D.new()
  end

  def look_from(arr, :top) do
    max_row = Arrays.size(arr) - 1
    max_col = Arrays.size(arr[0]) - 1
    for col <- 0..max_col do
      visible_trees(
        (for row <- 0..max_row, do: {row, col}),
        arr
      )
    end
      |> Array2D.new()
      |> Array2D.transpose()
  end

  def look_from(arr, :bottom) do
    max_row = Arrays.size(arr) - 1
    max_col = Arrays.size(arr[0]) - 1
    for col <- 0..max_col do
      visible_trees(
        (for row <- max_row..0//-1, do: {row, col}),
        arr
      )
      |> Enum.reverse()
    end
      |> Array2D.new()
      |> Array2D.transpose()
  end

  def visible_trees(coords, arr, hi \\ -1)
  def visible_trees([], _arr, _hi), do: []
  def visible_trees([{row, col} | next], arr, hi) do
    tree = arr[row][col]
    [tree > hi | visible_trees(next, arr, max(tree, hi))]
  end

  def line_of_sight(trees, height, count \\ 0)
  def line_of_sight([], _height, count), do: count
  def line_of_sight([tree | next], height, count) do
    if tree >= height do
      count + 1
    else
      line_of_sight(next, height, count + 1)
    end
  end

  def scenic_score(arr, row, col) do
    max_row = Arrays.size(arr) - 1
    max_col = Arrays.size(arr[0]) - 1
    if (row == 0 or col == 0) or (row == max_row or col == max_col) do
      0
    else
      height = arr[row][col]
      to_left = line_of_sight(
        Array2D.slice(arr, row, (col-1)..0//-1),
        height
      )
      to_right = line_of_sight(
        Array2D.slice(arr, row, (col+1)..max_col),
        height
      )
      to_top = line_of_sight(
        Array2D.slice(arr, (row-1)..0//-1, col),
        height
      )
      to_bottom = line_of_sight(
        Array2D.slice(arr, (row+1)..max_row, col),
        height
      )
      to_left * to_right * to_top * to_bottom
    end
  end
end

trees = File.read!("day8.txt")
  |> String.split("\n", [trim: true])
  |> Enum.map(fn(line) -> line
      |> String.to_charlist()
      |> Enum.map(&(&1 - ?0))
      |> Enum.into(Arrays.new())
  end)
  |> Enum.into(Arrays.new())

# IO.puts(Arrays.size(trees))
# IO.puts(Arrays.size(trees[0]))

# Part 1
from_left = trees |> Day8.look_from(:left)
from_right = trees |> Day8.look_from(:right)
from_top = trees |> Day8.look_from(:top)
from_bottom = trees |> Day8.look_from(:bottom)

zip = &Enum.zip(&1, Enum.flat_map(&2, fn(x) -> x end))
el_or = fn({x, y}) -> x or y end
part1 = from_left
  |> Enum.flat_map(&(&1))
  |> zip.(from_right)
  |> Enum.map(el_or)
  |> zip.(from_top)
  |> Enum.map(el_or)
  |> zip.(from_bottom)
  |> Enum.map(el_or)
  |> Enum.reduce(0, fn(bool, acc) -> (if bool, do: 1, else: 0) + acc end)
IO.puts("Part 1: #{part1}")

# Part 2
max_row = Arrays.size(trees) - 1
max_col = Arrays.size(trees[0]) - 1
part2 = for i <- 0..max_row, j <- 0..max_col do
  Day8.scenic_score(trees, i, j)
end
  |> Enum.max()

IO.puts("Part 2: #{part2}")


# Tried and failed to figure out how to use `mix test`
# arr = [
#   [3, 0, 3, 7, 3],
#   [2, 5, 5, 1, 2],
#   [6, 5, 3, 3, 2],
#   [3, 3, 5, 4, 9],
#   [3, 5, 3, 9, 0]
# ] |> Day8.Array2D.new()

# score = Day8.scenic_score(arr, 1, 2)
# if score != 4 do
#   raise "Score: #{score}"
# end

# score = Day8.scenic_score(arr, 3, 2)
# if score != 8 do
#   raise "Score: #{score}"
# end
