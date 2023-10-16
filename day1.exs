
defmodule Day1 do
    def parse_elves([], acc) do
        acc
    end

    def parse_elves([line | rest], [current | acc]) do
        case String.trim(line) do
            "" -> parse_elves(rest, [[]] ++ [current] ++ acc)
            num -> parse_elves(rest, [List.insert_at(current, 0, elem(Integer.parse(num), 0))] ++ acc)
        end
    end
end

elves = File.read!("day1.txt") |> String.split("\n") |> Day1.parse_elves([[]])

# calories |> IO.inspect(charlists: :as_lists)
calories  = elves |> Enum.map(&Enum.sum/1) |> Enum.sort(:desc)

IO.puts("Part 1: #{hd(calories)}")

top_three = calories |> Enum.take(3) |> Enum.sum()
IO.puts("Part 2: #{top_three}")
