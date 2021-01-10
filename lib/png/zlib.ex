defmodule Png.Zlib do
  @moduledoc """
  Wrapper around Erlangs :zlib
  """

  alias Png.BinaryHelpers

  @doc """
  compress data using :zlib.deflate

  options:  
  - level:  
    - one of:  
      - :none 
      - :default 
      - :best_compression 
      - :best_speed 
      - number in range 0..9
  """
  def compress(data, options \\ []) do
    level = Keyword.get(options, :level, :default)
    ref = :zlib.open()
    :ok = :zlib.deflateInit(ref, level)
    compressed = :zlib.deflate(ref, data, :finish)
    :zlib.close(ref)

    compressed
    |> :erlang.iolist_to_binary()
    |> BinaryHelpers.to_list()
  end

  @doc """
  decompress data using :zlib.inflate
  """
  def decompress(data) do
    ref = :zlib.open()
    :ok = :zlib.inflateInit(ref)
    uncompressed = :zlib.inflate(ref, data)

    :zlib.close(ref)

    uncompressed
    |> :erlang.iolist_to_binary()
    |> BinaryHelpers.to_list()
  end
end
