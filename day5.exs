
defmodule Day5 do
  def parse_line(crates, stacks, pos)

  def parse_line(<<crate::binary-size(4), rest::binary>>, stacks, pos) do
    case crate do
      <<_, ?\s, _, ?\s>> -> 
        parse_line(rest, stacks, pos+1)
      <<_, letter, _, ?\s>> ->
        parse_line(rest, put_elem(stacks, pos, elem(stacks, pos) ++ [letter]), pos+1)
    end
  end

  def parse_line(crate, stacks, pos) do
    case crate do
      <<_, ?\s, _>> -> stacks
      <<_, letter, _>> ->
        put_elem(stacks, pos, elem(stacks, pos) ++ [letter])
    end
  end

  def parse_instruction(["move", n, "from", start, "to", dest]) do
    {parse_int(n), parse_int(start), parse_int(dest)}
  end

  def parse_int(n) do
    elem(Integer.parse(n), 0)
  end

  def execute_instruction(stacks, instruction)

  def execute_instruction(stacks, {0, _, _}) do
    stacks
  end

  def execute_instruction(stacks, {n, start, dest}) do
    # IO.puts("#{n}, #{start}, #{dest}")
    case elem(stacks, start-1) do
      [crate | start_stack] -> stacks
        |> put_elem(start-1, start_stack)
        |> put_elem(dest-1, [crate | elem(stacks, dest-1)])
        |> execute_instruction({n-1, start, dest})
      [] -> stacks
    end
  end

  def execute_instruction2(stacks, {n, start, dest}) do
    moved = stacks |> elem(start-1) |> Enum.take(n)
    left = stacks |> elem(start-1) |> Enum.drop(n)

    stacks
      |> put_elem(start-1, left)
      |> put_elem(dest-1, moved ++ elem(stacks, dest-1))
  end
end


lines = File.read!("day5.txt")
  |> String.split("\n", [trim: true])
stacks = List.to_tuple(for _ <- 1..9, do: [])

stacks = lines
  |> Enum.take(8)
  |> Enum.reduce(stacks, fn(line, acc) -> Day5.parse_line(line, acc, 0) end)

instructions = lines
  |> Enum.slice(9..1000)
  |> Enum.map(&String.split(&1, " ", trim: true))
  |> Enum.map(&Day5.parse_instruction/1)

part1 = instructions
  |> Enum.reduce(stacks, fn(instruction, acc) -> Day5.execute_instruction(acc, instruction) end)
  |> Tuple.to_list()
  |> Enum.map(&hd/1)
IO.puts("Part 1: #{part1}")

part2 = instructions
  |> Enum.reduce(stacks, fn(instruction, acc) -> Day5.execute_instruction2(acc, instruction) end)
  |> Tuple.to_list()
  |> Enum.map(&hd/1)
IO.puts("Part 2: #{part2}")

