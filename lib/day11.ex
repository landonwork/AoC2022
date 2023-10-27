
defmodule Day11 do
end

defmodule Monkey do
  def parse([]), do: []
  def parse([line1, line2, line3, line4, line5, line6 | lines]) do
    # "Monkey " <> num = line1
    # num = Integer.parse(num) |> elem(0)

    "Starting items: " <> items = line2
    items = items
      |> String.split(", ")
      |> Enum.map(fn(x) -> elem(Integer.parse(x), 0) end)

    "Operation: new = " <> operation = line3
    operation = parse_operation(operation)

    "Test: divisible by " <> divisor = line4
    divisor = Integer.parse(divisor) |> elem(0)
    test = fn x -> rem(x, divisor) == 0 end

    "If true: throw to monkey " <> send_true = line5
    send_true = Integer.parse(send_true) |> elem(0)
    "If false: throw to monkey " <> send_false = line6
    send_false = Integer.parse(send_false) |> elem(0)

    monkey = make_monkey(operation, test, send_true, send_false)

    [{monkey, items} | parse(lines)]
  end

  def parse_operation(line) do
    [operand1, operator, operand2] = String.split(line, " ")
    operand1 = parse_operand(operand1)
    operator = parse_operator(operator)
    operand2 = parse_operand(operand2)
    fn(x) -> operator.(operand1.(x), operand2.(x)) end
  end

  def parse_operand(op) do
    case op do
      "old" -> fn(x) -> x end
      constant ->
        c = Integer.parse(constant) |> elem(0)
        fn(_x) -> c end
    end
  end

  def parse_operator("*"), do: &(&1 * &2)
  def parse_operator("+"), do: &(&1 + &2)

  def make_monkey(operation, test, send_true, send_false) do
    fn(x) ->
      x = operation.(x)
      x = div(x, 3)
      if test.(x), do: {send_true, x}, else: {send_false, x}
    end
  end

  @doc "The different actions the monkey can take"
  def monkey_time({tag, from, msg}) do
  end
end

input = General.lined_input("day11.txt")
monkeys = Monkey.parse(input)
# monkeys |> Enum.map(&elem(&1, 1)) |> IO.inspect(charlists: :as_lists)
