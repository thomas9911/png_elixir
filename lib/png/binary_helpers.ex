defmodule Png.BinaryHelpers do
  def to_uint(binary) when is_binary(binary) do
    :binary.decode_unsigned(binary, :big)
  end

  def from_uint(number, bytes) do
    number
    |> :binary.encode_unsigned(:big)
    |> String.pad_leading(bytes, <<0>>)
  end

  def to_list(<<x::1>>), do: [x]
  def to_list(<<x::2>>), do: [x]
  def to_list(<<x::3>>), do: [x]
  def to_list(<<x::4>>), do: [x]

  def to_list(binary) do
    :binary.bin_to_list(binary)
  end

  def from_list(list) do
    :binary.list_to_bin(list)
  end
end
