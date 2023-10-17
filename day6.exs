
defmodule Day6 do
  def find_packet(str, pos \\ 4)

  def find_packet(<<quad::binary-size(4), rest::binary>>, pos) do
    case quad do
      <<_b, _c, a, a>> -> find_packet(<<a>> <> rest, pos + 3)
      <<_b, a, c, a>> -> find_packet(<<c, a>> <> rest, pos + 2)
      <<a, b, c, a>> -> find_packet(<<b, c, a>> <> rest, pos + 1)
      <<_b, a, a, c>> -> find_packet(<<a, c>> <> rest, pos + 2)
      <<a, b, a, c>> -> find_packet(<<b, a, c>> <> rest, pos + 1)
      <<a, a, b, c>> -> find_packet(<<a, b, c>> <> rest, pos + 1)
      <<_, _, _, _>> -> pos
    end
  end

  def find_packet(_no_packet, _pos) do
    nil
  end

  def find_message(signal) do
    incoming = String.to_charlist(signal)
    outgoing = (for _ <- 1..14, do: nil) ++ incoming
    freqs = %{}
    find_message(incoming, outgoing, freqs, 0)
  end

  def find_message([next_in | incoming], [next_out | outgoing], freqs, pos) do
    freqs = freqs
      |> Map.get_and_update(next_in, &one_incoming/1)
      |> elem(1)
      |> Map.get_and_update(next_out, &one_leaving/1)
      |> elem(1)

    if map_size(freqs) == 14 do
      IO.inspect(freqs, charlists: :as_strings)
      pos + 1
    else
      find_message(incoming, outgoing, freqs, pos + 1)
    end
  end

  defp one_leaving(n) do
    if is_nil(n) or n <= 1 do
      :pop
    else
      {n, n - 1}
    end
  end

  defp one_incoming(n) when is_nil(n) do
    {0, 1}
  end

  defp one_incoming(n) when is_integer(n) do
    {n, n + 1}
  end
end

signal = File.read!("day6.txt") |> String.trim()
first_packet = Day6.find_packet(signal)
IO.puts("Part 1: #{first_packet}")

first_message = signal |> Day6.find_message()
IO.puts("Part 2: #{first_message}")
