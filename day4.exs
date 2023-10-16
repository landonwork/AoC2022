
defmodule Day4 do
  def parse_range(range) do
    range
      |> String.split("-")
      |> Enum.map(&(Integer.parse(&1) |> elem(0)))
  end

  def parse_pair(pair) do
    pair
      |> String.split(",")
      |> Enum.map(&parse_range/1)
  end

  def range_contains([lo1, hi1], [lo2, hi2]) do
    lo1 <= lo2 and hi1 >= hi2
  end

  def redundant_ranges([range1, range2]) do
    range_contains(range1, range2) or range_contains(range2, range1)
  end

  def range_overlaps([lo1, hi1], [lo2, hi2]) do
    (lo1 <= lo2 and hi1 >= lo2) or (lo1 <= hi2 and hi1 >= hi2)
  end

  def ranges_overlap([range1, range2]) do
    range_overlaps(range1, range2) or range_overlaps(range2, range1)
  end
end

assignments = File.read!("day4.txt") |> String.split("\n", [trim: true])
pairs = assignments |> Enum.map(&Day4.parse_pair/1)

# pairs |> IO.inspect(charlists: :as_lists)

n_contained = pairs
  |> Enum.map(&Day4.redundant_ranges/1)
  |> Enum.map(&(if &1 do 1 else 0 end))
  |> Enum.sum()

IO.puts("Part 1: #{n_contained}")

n_overlapping = pairs
  |> Enum.map(&Day4.ranges_overlap/1)
  |> Enum.map(&(if &1 do 1 else 0 end))
  |> Enum.sum()

IO.puts("Part 2: #{n_overlapping}")
