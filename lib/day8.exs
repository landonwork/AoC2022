
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
