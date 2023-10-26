
defmodule Day10 do
  def to_instruction(line) do
    case line do
      "addx " <> num -> {
          :addx,
          num |> Integer.parse() |> elem(0)
        }
      "noop" <> _ -> {:noop}
    end
  end

  def part1(input) do
    cpu = CPU.start_link(input)
    ticks = for _ <- 1..240, do: GenServer.call(cpu, :tick)
    signals = for {tick, x} <- ticks, rem(tick, 40) == 20, do: tick * x
    Enum.sum(signals)
  end

  def lit?(pos, sprite_center) do
    if pos >= sprite_center - 1 and pos <= sprite_center + 1 do
      "#"
    else
      "."
    end
  end
end

defmodule CPU do
  use GenServer

  def start_link(instructions, opts \\ []) do
    {:ok, cpu} = GenServer.start_link(__MODULE__, instructions, opts)
    cpu
  end

  @impl true
  def init(instructions) do
    # {tick, x, instructions}
    {:ok, {1, 1, instructions}}
  end

  @impl true
  def handle_call(:tick, _from, {tick, x, instructions}) do
    response = {tick, x}
    {new_x, rest} = cycle(x, instructions)
    {:reply, response, {tick + 1, new_x, rest}}
  end

  def cycle(x, []) do
    {x, []}
  end

  def cycle(x, [ins | rest]) do
    case ins do
      {:noop} -> {x, rest}
      {:addx, num} -> {x, [{:addnow, num} | rest]}
      {:addnow, num} -> {x + num, rest}
    end
  end
end


input = General.lined_input("day10.txt")
  |> Enum.map(&Day10.to_instruction/1)
cpu = CPU.start_link(input)
ticks = for _ <- 1..240, do: GenServer.call(cpu, :tick)
signals = for {tick, x} <- ticks, rem(tick, 40) == 20, do: tick * x
total = Enum.sum(signals)
IO.puts("Part 1: #{total}")

screen = Enum.map(ticks, fn({tick, x}) -> Day10.lit?(rem(tick-1, 40), x) end)
screen
  |> Enum.chunk_every(40)
  |> Enum.map(&Enum.join(&1, ""))
  |> Enum.map(&IO.inspect(&1, binaries: :as_strings))
