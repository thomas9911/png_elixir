defmodule Png.Chunk do
  defstruct len: nil, data: nil, type: nil, crc: nil

  @type t :: %__MODULE__{}

  alias Png.BinaryHelpers

  @callback parse(__MODULE__.t(), map) :: map
  @callback parameter() :: {:struct | :list, atom}

  defguard is_valid(chunk)
           when is_integer(:erlang.map_get(:len, chunk)) and
                  is_list(:erlang.map_get(:data, chunk)) and
                  is_binary(:erlang.map_get(:type, chunk)) and
                  is_integer(:erlang.map_get(:crc, chunk))

  def new(data, type) do
    chunk = %__MODULE__{
      len: length(data),
      type: type,
      data: data
    }

    crc = calculate_crc(chunk)
    %{chunk | crc: crc}
  end

  def dump(%__MODULE__{len: len, type: type, data: data, crc: crc}) do
    [
      len |> BinaryHelpers.from_uint(4) |> BinaryHelpers.to_list(),
      BinaryHelpers.to_list(type),
      data,
      crc |> BinaryHelpers.from_uint(4) |> BinaryHelpers.to_list()
    ]
    |> Enum.concat()
  end

  def calculate_crc(%__MODULE__{type: type, data: data}) do
    :erlang.crc32([BinaryHelpers.to_list(type) | data])
  end

  def valid_crc?(%__MODULE__{crc: nil}) do
    false
  end

  def valid_crc?(%__MODULE__{crc: crc} = chunk) do
    __MODULE__.calculate_crc(chunk) == crc
  end

  def parse(input) do
    do_parse({input, %__MODULE__{}})
  end

  defp do_parse({rest, chunk}) when is_valid(chunk) do
    {:ok, chunk, rest}
  end

  defp do_parse(
         {[a, b, c, d | rest] = _input,
          acc = %__MODULE__{len: nil, data: nil, type: nil, crc: nil}}
       ) do
    length = BinaryHelpers.to_uint(<<a, b, c, d>>)
    do_parse({rest, %{acc | len: length}})
  end

  defp do_parse(
         {[a, b, c, d | rest] = _input,
          acc = %__MODULE__{len: len, data: nil, type: nil, crc: nil}}
       )
       when is_integer(len) do
    type = <<a, b, c, d>>
    do_parse({rest, %{acc | type: type}})
  end

  defp do_parse({input, acc = %__MODULE__{len: len, data: nil, type: type, crc: nil}})
       when is_integer(len) and is_binary(type) do
    {bytes, rest} = Enum.split(input, len)

    if length(bytes) == len do
      acc = %{acc | data: bytes}

      do_parse({rest, acc})
    else
      {:error, :invalid_chunk_data}
    end
  end

  defp do_parse(
         {[a, b, c, d | rest] = _input,
          acc = %__MODULE__{len: len, data: data, type: type, crc: nil}}
       )
       when is_integer(len) and is_binary(type) and is_list(data) do
    crc = BinaryHelpers.to_uint(<<a, b, c, d>>)
    do_parse({rest, %{acc | crc: crc}})
  end

  defp do_parse(_acc) do
    {:error, :invalid_chunk}
  end
end
