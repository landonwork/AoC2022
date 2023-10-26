
defmodule Day9 do
  def dx_dy(line) do
    [dir, num] = String.split(line, " ")
    num = Integer.parse(num) |> elem(0)
    case dir do
      "U" -> {0, num}
      "R" -> {num, 0}
      "D" -> {0, -num}
      "L" -> {-num, 0}
    end
  end
end

defmodule Rope do
  use GenServer

  def start_link(length, opts \\ []) do
    GenServer.start_link(__MODULE__, length, opts)
  end

  @impl true
  def init(length) do
    if length < 1 do
      :error
    else
      {:ok,
        {
          (for _ <- 1..length, do: {0, 0}),
          MapSet.new([{0, 0}])
        }
      }
    end
  end

  @impl true
  def handle_call({:get, :hist}, _from, {_rope, spaces} = state) do
    {:reply, spaces, state}
  end

  @impl true
  def handle_cast({:move, {0, 0}}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:move, mvmt}, {rope, spaces}) do
    {rope, tip, mvmt} = move_rope(rope, mvmt)
    spaces = MapSet.put(spaces, tip)
    handle_cast({:move, mvmt}, {rope, spaces})
  end

  def move_rope([{hx, hy} | tail], {dx, dy}) do
    head = {hx + sign(dx), hy + sign(dy)}
    {rope, tip} = update_tail([head | tail])
    mvmt = {dx - sign(dx), dy - sign(dy)}
    {rope, tip, mvmt}
  end

  def update_tail([head]), do: {[head], head}
  def update_tail([head, tail | rest]) do
    {hx, hy} = head
    {tx, ty} = tail
    {diffx, diffy} = {hx - tx, hy - ty}
    if abs(diffx) > 1 or abs(diffy) > 1 do
      tail = {tx + sign(diffx), ty + sign(diffy)}
      {rope, tip} = update_tail([tail | rest])
      {[head | rope], tip}
    else
      case rest do  # Match to find the tip
        [] -> {[head, tail], tail}
        rest -> {[head, tail | rest], List.last(rest)}
      end
    end
  end

  def sign(num) do
    cond do
      num < 0 -> -1
      num == 0 -> 0
      num > 0 -> 1
    end
  end
end

input = File.read!("day9.txt") |> String.split("\n", trim: true)
{:ok, rope} = Rope.start_link(2)
input 
  |> Enum.map(&Day9.dx_dy/1)
  |> Enum.each(&GenServer.cast(rope, {:move, &1}))
spaces = GenServer.call(rope, {:get, :hist})
IO.puts("Part 1: #{MapSet.size(spaces)}")


{:ok, rope} = Rope.start_link(10)
input 
  |> Enum.map(&Day9.dx_dy/1)
  |> Enum.each(&GenServer.cast(rope, {:move, &1}))
spaces = GenServer.call(rope, {:get, :hist})
IO.puts("Part 2: #{MapSet.size(spaces)}")

# Test 1
# test1 = "R 4
# U 4
# L 3
# D 1
# R 4
# D 1
# L 5
# R 2"
# test1 = test1 |> String.split("\n", trim: true) |> Enum.map(&Day9.dx_dy/1)
# {:ok, rope} = Rope.start_link(2)
# Enum.each(test1, &GenServer.cast(rope, {:move, &1}))
# spaces = GenServer.call(rope, {:get, :hist})
# IO.puts("Test 1: #{MapSet.size(spaces)}")

# Test 2
# test2 = "R 5
# U 8
# L 8
# D 3
# R 17
# D 10
# L 25
# U 20"
# test2 = test2 |> String.split("\n", trim: true) |> Enum.map(&Day9.dx_dy/1)
# {:ok, rope} = Rope.start_link(10)
# Enum.each(test2, &GenServer.cast(rope, {:move, &1}))
# spaces = GenServer.call(rope, {:get, :hist})
# IO.puts("Test 2: #{MapSet.size(spaces)}")
