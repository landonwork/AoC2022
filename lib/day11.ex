# It made me move the monkey struct to a completely different file
# Stuff about cyclic blah blah
defmodule Day11 do
  @mod_constant Enum.product([2, 3, 5, 7, 11, 13, 17, 19])

  def parse_monkey([]), do: []
  def parse_monkey([_line1, line2, line3, line4, line5, line6 | lines]) do
    # "Monkey " <> num = _line1
    # num = Integer.parse(num) |> elem(0)

    "Starting items: " <> items = line2

    items =
      items
      |> String.split(", ")
      |> Enum.map(fn x -> elem(Integer.parse(x), 0) end)

    "Operation: new = " <> operation = line3
    operation = parse_operation(operation)

    "Test: divisible by " <> divisor = line4
    divisor = Integer.parse(divisor) |> elem(0)
    test = fn x -> rem(x, divisor) == 0 end

    "If true: throw to monkey " <> send_true = line5
    send_true = Integer.parse(send_true) |> elem(0)
    "If false: throw to monkey " <> send_false = line6
    send_false = Integer.parse(send_false) |> elem(0)

    brain = make_brain(operation, test, send_true, send_false)

    [{brain, items} | parse_monkey(lines)]
  end

  def parse_operation(line) do
    [operand1, operator, operand2] = String.split(line, " ")
    operand1 = parse_operand(operand1)
    operator = parse_operator(operator)
    operand2 = parse_operand(operand2)
    fn x -> operator.(operand1.(x), operand2.(x)) end
  end

  def parse_operand(op) do
    case op do
      "old" ->
        fn x -> x end

      constant ->
        c = Integer.parse(constant) |> elem(0)
        fn _x -> c end
    end
  end

  def parse_operator("*"), do: &(&1 * &2)
  def parse_operator("+"), do: &(&1 + &2)

  def make_brain(operation, test, send_true, send_false) do
    fn x ->
      x = operation.(x)
      # x = div(x, 3)
      x = rem(x, @mod_constant)
      if test.(x), do: {send_true, x}, else: {send_false, x}
    end
  end

  @doc "The monkey taking its turn"
  def monkey_time(%Monkey{items: []} = state), do: state
  def monkey_time(state) do
    [item | rest] = state.items
    {dest, item} = state.brain.(item)
    send(lookup(dest), {:catch, item})
    monkey_time(%{state | items: rest, count: state.count + 1})
  end

  @doc "The monkey process"
  def monkey_brain(%Monkey{} = state) do
    # {:get, from} | {:catch, item} | {:play, from}
    receive do
      {:get, from} ->
        send(from, state.count)
        monkey_brain(state)
      {:catch, item} ->
        # IO.puts("Monkey #{state.name} caught #{item}!")
        monkey_brain(%{state | items: state.items ++ [item]})
      {:play, from} ->
        new_state = monkey_time(state)
        send(from, :ok)
        # IO.puts("Monkey #{new_state.name} has played with #{new_state.count} toys")
        monkey_brain(new_state)
    end
  end

  def start(id, monkey) do
    pid = spawn(fn -> monkey_brain(monkey) end)
    Registry.register(__MODULE__, id, pid)
  end

  def lookup(i) do
    case Registry.lookup(__MODULE__, i) do
      [] -> []
      [{_, pid}] -> pid
    end
  end
end

alias Monkey

input = General.lined_input("day11.txt")
monkeys = Day11.parse_monkey(input)
{:ok, _} = Registry.start_link(keys: :unique, name: Day11)

monkeys
|> Enum.with_index()
|> Enum.map(fn {{brain, items}, i} -> %Monkey{ brain: brain, items: items, name: i } end)
|> Enum.each(fn(monkey) -> Day11.start(monkey.name, monkey) end)

for round <- 1..10000, i <- 0..7 do
  if i == 0, do: IO.puts(round)
  send(Day11.lookup(i), {:play, self()})
  receive do
    :ok -> nil
  end
end

counts = for i <- 0..7 do
  send(Day11.lookup(i), {:get, self()})
  receive do
    count -> count
  end
end

monkey_business = counts
|> Enum.sort()
|> Enum.chunk_every(2)
|> Enum.max()
|> Enum.product()

IO.puts("Part 2: #{monkey_business}")





