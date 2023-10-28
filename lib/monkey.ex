defmodule Monkey do
  @enforce_keys [:items, :brain]
  defstruct [:items, :brain, :name, count: 0]
end

