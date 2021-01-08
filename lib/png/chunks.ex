defmodule Png.Chunks do
  alias Png.Chunk
  alias Png.Chunk.Data
  alias Png.Chunk.DataEnd
  alias Png.Chunk.Header
  alias Png.Chunk.Unhandled

  @required [:header, :data, :pallette, :data_buffer]
  @signature [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

  @spec interpret([Chunk.t()]) :: Png.t()
  def interpret(chunks) do
    do_interpret(chunks, %Png{})
  end

  defp do_interpret([], png) do
    {:ok, Map.put(png, :data_buffer, [])}
  end

  defp do_interpret([%Chunk{type: type} = chunk | tail], png) do
    if Chunk.valid_crc?(chunk) do
      module = chunk_module(type)

      png =
        chunk
        |> module.parse(png)
        |> add(module.parameter(), png)

      do_interpret(tail, png)
    else
      {:error, :invalid_crc}
    end
  end

  @spec interpret([Chunk.t()]) :: list
  def dump(chunks) do
    chunks = chunks |> Enum.map(&Chunk.dump/1)

    [@signature | chunks]
    |> List.flatten()
  end

  defp chunk_module("IDAT"), do: Data
  defp chunk_module("IHDR"), do: Header
  defp chunk_module("IEND"), do: DataEnd
  defp chunk_module(_), do: Unhandled

  defp add(_result, nil, png), do: png

  defp add(result, {:struct, key}, png) when key in @required do
    Map.put(png, key, result)
  end

  defp add(result, {:struct, key}, %{extra: extra} = png) do
    extra = Map.put(extra, key, result)
    Map.put(png, :extra, extra)
  end

  defp add(result, {:list, key}, png) when key in @required do
    list = Map.get(png, key) || []
    list = [result | list]
    Map.put(png, key, list)
  end

  defp add(result, {:list, key}, %{extra: extra} = png) do
    list = Map.get(extra, key) || []
    list = [result | list]
    extra = Map.put(extra, key, list)

    Map.put(png, :extra, extra)
  end
end
