defmodule Png.Chunker do
  alias Png.Chunk
  alias Png.Chunk.Data
  alias Png.Chunk.Header
  alias Png.Chunk.Unhandled

  def build(png) do
    Enum.flat_map([:header, :unhandled, :data, :end], &do_build(png, &1))
  end

  defp do_build(%{header: header} = _png, :header) do
    header
    |> Header.to_chunk_data()
    |> Chunk.new("IHDR")
    |> List.wrap()
  end

  defp do_build(%{extra: extra} = _png, :unhandled) do
    extra
    |> Map.get(:unhandled, [])
    |> Enum.map(&Unhandled.to_chunk/1)
    |> :lists.reverse()
  end

  defp do_build(png, :data) do
    png
    |> Data.to_chunk_data()
    |> Chunk.new("IDAT")
    |> List.wrap()
  end

  defp do_build(_png, :end) do
    []
    |> Chunk.new("IEND")
    |> List.wrap()
  end
end
