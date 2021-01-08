defmodule Png.Chunk.DataEnd do
  alias Png.Zlib

  @behaviour Png.Chunk

  alias Png.BinaryHelpers

  @impl true
  def parse(%{data: []}, %{data_buffer: bytes, header: %{height: height}} = png) do
    raw_bytes =
      bytes
      |> :lists.reverse()
      |> :lists.flatten()
      |> Zlib.decompress()
      |> BinaryHelpers.from_list()

    parse_lines(raw_bytes, [], height, png)
  end

  defp parse_lines(_input, output, 0, _png) do
    :lists.reverse(output)
  end

  defp parse_lines(
         <<_filter_type::8, input::bitstring>>,
         output,
         remaining_lines,
         %{header: %{width: width, color_type: color_type, depth: depth}} = png
       ) do
    {rest, pixels} = parse_pixels(input, [], width, color_type_size(color_type), depth)
    parse_lines(rest, [pixels | output], remaining_lines - 1, png)
  end

  defp parse_lines(_input, _, _remaining_lines, _png) do
    raise "invalid png"
  end

  defp parse_pixels(input, output, 0, _pixel_size, _depth) do
    {input, :lists.reverse(output)}
  end

  defp parse_pixels(input, output, remaining_pixels, pixel_size, depth) do
    n = pixel_size * depth
    <<chunk::size(n), rest::bitstring>> = input

    pixel = BinaryHelpers.to_list(<<chunk::size(n)>>)

    parse_pixels(rest, [pixel | output], remaining_pixels - 1, pixel_size, depth)
  end

  # Gray
  def color_type_size(0), do: 1

  # RGB
  def color_type_size(2), do: 3

  # Indexed
  def color_type_size(3), do: 1

  # Gray and Alpha
  def color_type_size(4), do: 2

  # RGBA
  def color_type_size(6), do: 4

  @impl true
  def parameter(), do: {:struct, :data}
end

# <<a::1, b::1, c::1, d::1, e::1, f::1, g::1, h::1>>
