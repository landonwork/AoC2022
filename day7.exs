defmodule Day7 do
  defprotocol FileSize do
    def file_size(data)
  end

  defmodule File_ do
    @enforce_keys [:bytes]
    defstruct [:bytes]
  end

  defimpl FileSize, for: File_ do
    def file_size(file), do: file.bytes
  end

  defimpl FileSize, for: Map do
    def file_size(map),
      do: Enum.reduce(
          map, 0, fn({_, obj}, acc) ->
            FileSize.file_size(obj) + acc end
        )
  end

  def execute_lines(device, lines, contents \\ nil)

  def execute_lines(device, [next | lines], nil) do
    # GenServer.call(device, {:get, :pwd}) |> IO.inspect()
    case next do
      "$ cd /" ->
        GenServer.cast(device, {:cd, ["/"]})
        execute_lines(device, lines)
      "$ cd " <> path ->
        GenServer.cast(device, {:cd, String.split(path, "/")})
        execute_lines(device, lines)
      "$ ls" -> execute_lines(device, lines, [])
    end
  end

  def execute_lines(device, lines, contents) do
    case lines do
      ["$ " <> next | lines] ->
        GenServer.cast(device, {:ls, contents})
        execute_lines(device, ["$ " <> next | lines])
      [next | lines] ->
        execute_lines(device, lines, [next | contents])
      [] -> GenServer.cast(device, {:ls, contents})
    end
  end

  def part1(map, acc \\ 0)

  def part1({_, %File_{}}, acc) do
    acc
  end

  def part1({_, map}, acc) when is_map(map) do
    size = FileSize.file_size(map)
    size = if size <= 100000, do: size, else: 0
    Enum.reduce(map, acc + size, &part1/2)
  end

  def part2(tuple, target, best \\ 70000000)

  def part2({_, %File_{}}, _, best) do
    best
  end

  def part2({_, map}, target, best) when is_map(map) do
    IO.puts(best)
    size = FileSize.file_size(map)
    best = if size > target, do: min(size, best), else: best
    Enum.reduce(map, best, &part2(&1, target, &2))
  end
end

defmodule FileSystem do
  alias Day7.File_
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  # init return {:result, state}
  @impl true
  def init(:ok) do
    {:ok, {[], %{"/" => %{}}}}
  end

  # handle_call *must* send a response back
  # handle_cast does not send a response
  # handle_call's input is (request, _from, state)
  # handle_call's output is always {:reply, response, new_state}
  # handle_cast's input is (request, state)
  # handle_cast's output is {:noreply, new_state}
  @impl true
  def handle_call({:get, :all}, _from, device) do
    {:reply, device, device}
  end

  @impl true
  def handle_call({:get, :fs}, _from, {_pwd, fs} = device) do
    {:reply, fs, device}
  end

  @impl true
  def handle_call({:get, :pwd}, _from, {pwd, _fs} = device) do
    {:reply, pwd, device}
  end

  @impl true
  def handle_cast({:ls, contents}, {pwd, fs}) do
    {:noreply, {pwd, add_contents(Enum.reverse(pwd), fs, contents)}}
  end

  @impl true
  def handle_cast({:cd, path}, {pwd, fs}) do
    {:noreply, {cd(pwd, path), fs}}
  end

  def add_contents(_path, fs, []), do: fs

  def add_contents(path, fs, [next | contents]) do
    {name, obj} = case String.split(next, " ") do
      ["dir", name] -> {name, %{}}
      [size, name] -> {
          name,
          %File_{
            bytes: size
              |> Integer.parse()
              |> elem(0)
          }
        }
    end
    fs = put_in(fs, path ++ [name], obj)
    add_contents(path, fs, contents)
  end

  def cd(pwd, []) do
    pwd
  end

  def cd(pwd, [next | path]) do
    case next do
      ".." -> cd(Enum.drop(pwd, 1), path)
      dir -> cd([dir | pwd], path)
    end
  end
end

alias Day7.FileSize

# Setup
{:ok, device} = GenServer.start_link(FileSystem, :ok)

lines = File.read!("day7.txt") |> String.split("\n", [trim: true])
Day7.execute_lines(device, lines)
# GenServer.call(device, {:get, :fs}) |> IO.inspect()

# Part 1
fs = GenServer.call(device, {:get, :fs})
ans = Enum.reduce(fs, 0, &Day7.part1/2)
IO.puts("Part 1: #{ans}")

# Part 2
total = FileSize.file_size(fs)
IO.puts("Space used: #{total}")
target = 30000000 - (70000000 - total)
IO.puts("Space to free #{target}")

ans = Enum.reduce(fs, total, &Day7.part2(&1, target, &2))
IO.puts("Part 2: #{ans}")
