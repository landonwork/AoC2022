
defmodule General do
  def lined_input(name) do
    name |> File.read!() |> String.split("\n", trim: true)
  end
end
