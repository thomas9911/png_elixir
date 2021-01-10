defmodule Png.Chunk.Data do
  @behaviour Png.Chunk

  alias Png.Zlib

  @impl true
  def parse(%{data: bytes}, _) do
    bytes
  end

  @impl true
  def parameter(), do: {:list, :data_buffer}

  def to_chunk_data(%Png{data: data, header: %{filter_method: filter_method}}) do
    data
    |> Enum.map(fn x -> [filter_method | x] end)
    |> List.flatten()
    |> Zlib.compress(level: 9)
  end
end
