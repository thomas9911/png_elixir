defmodule Png.Chunk.Unhandled do
  defstruct [:raw, :raw_type]

  @behaviour Png.Chunk

  alias Png.BinaryHelpers
  alias Png.Chunk

  @impl true
  def parse(%{data: data, type: type}, _) do
    %__MODULE__{raw: data, raw_type: type}
    # |> IO.inspect()
  end

  @impl true
  def parameter(), do: {:list, :unhandled}

  def to_chunk_data(%__MODULE__{
        raw: raw,
        raw_type: raw_type
      }) do
    BinaryHelpers.to_list(raw_type) ++ raw
  end

  def to_chunk(
        %__MODULE__{
          raw_type: raw_type
        } = prop
      ) do
    Chunk.new(to_chunk_data(prop), raw_type)
  end
end
