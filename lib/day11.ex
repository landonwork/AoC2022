# It made me move the monkey struct to a completely different file
# Stuff about cyclic blah blah
defmodule Day11 do
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
      x = div(x, 3)
      if test.(x), do: {send_true, x}, else: {send_false, x}
    end
  end

  @doc "The monkey taking its turn"
  def monkey_time(%Monkey{items: []}), do: nil

  def monkey_time(state) do
    [item | rest] = state.items
    {dest, item} = state.brain.(item)
    pid = Registry.lookup(__MODULE__, dest)
    send(pid, item)
    monkey_time(%{state | items: rest})
  end

  @doc "The monkey process"
  def monkey_brain(%Monkey{} = state) do
    # {:catch, item} | {:play, from}
    receive do
      {:get, from} ->
        send(from, state.count)
        monkey_brain(state)
      {:catch, item} ->
        monkey_brain(%{state | items: state.items ++ [item]})
      {:play, from} ->
        # TODO: play with the items and throw them to other monkeys
        send(from, :ok)
        monkey_brain(%{state | items: []})
    end
  end

  def start(id, monkey) do
    pid = spawn(fn -> monkey_brain(monkey) end)
    Registry.register(__MODULE__, id, pid)
  end
end

alias Monkey

input = General.lined_input("day11.txt")
monkeys = Day11.parse_monkey(input)
{:ok, _} = Registry.start_link(keys: :unique, name: Day11)

monkeys
|> Enum.map(fn {brain, items} -> %Monkey{ brain: brain, items: items } end)
|> Enum.with_index()
|> Enum.each(fn({monkey, id}) -> Day11.start(id, monkey) end)

[{_self, pid}] = Registry.lookup(Day11, 1)
send(pid, {:get, self()})

receive do
  num -> IO.inspect(num)
end

send(pid, {:play, self()})
receive do
  :ok -> nil
end

send(pid, {:get, self()})
receive do
  :ok -> nil
end
