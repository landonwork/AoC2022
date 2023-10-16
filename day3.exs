
defmodule Day3 do
    def intersection(sack) do
        size = Kernel.byte_size(sack)
        lst = sack |> String.to_charlist()
        # lst |> IO.inspect(charlist: :as_lists)
        compartments = lst |> Enum.chunk_every(div(size, 2))
        compartments
          |> Enum.map(&MapSet.new/1)
          |> Enum.reduce(&MapSet.intersection/2)
    end

    def char_to_priority(char) do
        cond do
            char >= ?a and char <= ?z ->  char + 1 - ?a
            char >= ?A and char <= ?Z ->  char + 27 - ?A
            true -> raise("This error should never be raised") 
        end
    end
end

## Part 1
sacks = File.read!("day3.txt") |> String.split("\n", [trim: true])
intersections = sacks |> Enum.map(&Day3.intersection/1) |> Enum.flat_map(fn(x) -> x end)
# intersections |> IO.inspect(charlists: :as_lists)
priorities = intersections |> Enum.map(&Day3.char_to_priority/1)
total = priorities |> Enum.sum()
IO.puts("Part 1: #{total}")

## Part 2
intersection = &MapSet.intersection/2  # Because nested captures aren't allowed
groups = sacks
  |> Enum.map(&(String.to_charlist(&1) |> MapSet.new()))
  |> Enum.chunk_every(3)
badges = groups
  |> Enum.map(&(Enum.reduce(&1, intersection)))
  |> Enum.flat_map(fn(x) -> x end)
priorities = badges |> Enum.map(&Day3.char_to_priority/1)
total = priorities |> Enum.sum()
IO.puts("Part 2: #{total}")
