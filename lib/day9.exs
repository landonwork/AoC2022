
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

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok,
      {
        {{0, 0}, {0, 0}},
        MapSet.new([{0, 0}])
      }
    }
  end

  @impl true
  def handle_call({:get, :hist}, _from, {_rope, spaces} = state) do
    {:reply, spaces, state}
  end

  @impl true
  def handle_cast({:move, {0, 0}}, state) do
    # IO.inspect(state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:move, mvmt}, {rope, spaces}) do
    {rope, mvmt} = move_rope(rope, mvmt)
    spaces = MapSet.put(spaces, elem(rope, 1))
    handle_cast({:move, mvmt}, {rope, spaces})
  end

  def move_rope({{hx, hy}, tail} = rope, mvmt) do
    case mvmt do
      {0, 0} -> rope  # This should be unreachable
      {dx, 0} ->
        head = {hx + sign(dx), hy}
        {
          {head, update_tail(head, tail)},
          {dx - sign(dx), 0}
        }
      {0, dy} ->
        head = {hx, hy + sign(dy)}
        {
          {head, update_tail(head, tail)},
          {0, dy - sign(dy)}
        }
      {dx, dy} -> 
        head = {hx + sign(dx), hy + sign(dy)}
        {
          {head, update_tail(head, tail)},
          {dx - sign(dx), dy - sign(dy)}
        }
    end
  end

  def update_tail({hx, hy}, {tx, ty}) do
    diffx = hx - tx
    diffy = hy - ty
    if abs(diffx) > 1 or abs(diffy) > 1 do
      cond do
        abs(diffx) > 0 and abs(diffy) > 0 ->
            {tx + sign(diffx), ty + sign(diffy)}
        abs(diffx) > 1 -> {tx + sign(diffx), ty} 
        abs(diffy) > 1 -> {tx, ty + sign(diffy)} 
        true -> {tx, ty}
      end
    else
      {tx, ty}
    end
  end

  def sign(num) do
    if num < 0, do: -1, else: 1
  end
end

input = File.read!("day9.txt") |> String.split("\n", trim: true)
{:ok, rope} = Rope.start_link()
input 
  |> Enum.map(&Day9.dx_dy/1)
  |> Enum.each(&GenServer.cast(rope, {:move, &1}))
spaces = GenServer.call(rope, {:get, :hist})
IO.puts("Part 1: #{MapSet.size(spaces)}")


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
# {:ok, rope} = Rope.start_link()
# Enum.each(test1, &GenServer.cast(rope, {:move, &1}))
# spaces = GenServer.call(rope, {:get, :hist})
# IO.puts("Test 1: #{MapSet.size(spaces)}")
