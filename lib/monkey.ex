defmodule Monkey do
  @enforce_keys [:items, :brain]
  defstruct [:items, :brain, count: 0]
end

