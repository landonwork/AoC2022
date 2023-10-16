
defmodule Day2 do
    def score(round) do
        case round do
            "A X" -> 4
            "A Y" -> 8
            "A Z" -> 3
            "B X" -> 1
            "B Y" -> 5
            "B Z" -> 9
            "C X" -> 7
            "C Y" -> 2
            "C Z" -> 6
            "" -> 0
        end
    end

    def score2(round) do
        case round do
            "A X" -> score("A Z")
            "A Y" -> score("A X")
            "A Z" -> score("A Y")
            "B X" -> score("B X")
            "B Y" -> score("B Y")
            "B Z" -> score("B Z")
            "C X" -> score("C Y")
            "C Y" -> score("C Z")
            "C Z" -> score("C X")
            "" -> 0
        end
    end
end

guide = File.read!("day2.txt")
  |> String.split("\n")
  |> Enum.map(&String.trim/1)
rounds = guide |> Enum.map(&Day2.score/1)
total = rounds |> Enum.sum()
IO.puts("Part 1: #{total}")

total2 = guide |> Enum.map(&Day2.score2/1) |> Enum.sum()
IO.puts("Part 2: #{total2}")

