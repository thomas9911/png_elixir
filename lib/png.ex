defmodule Png do
  defstruct header: %{}, data: [], pallete: nil, extra: %{}, data_buffer: []

  alias Png.BinaryHelpers
  alias Png.Chunk.Header

  @type pixel :: [color_value :: byte]
  @type t :: %__MODULE__{
          header: map,
          data: [[pixel]],
          pallete: map | nil,
          extra: map,
          data_buffer: any
        }

  def decode(binary) when is_list(binary) do
    with {:ok, chunks} <- Png.Parser.parse(binary),
         {:ok, png} = Png.Chunks.interpret(chunks) do
      {:ok, png}
    end
  end

  def decode(binary) when is_binary(binary) do
    binary
    |> BinaryHelpers.to_list()
    |> decode()
  end

  def encode(%__MODULE__{} = png) do
    png
    |> Png.Chunker.build()
    |> Png.Chunks.dump()
  end

  def file(path) do
    case File.read(path) do
      {:ok, binary} -> decode(binary)
      e -> e
    end
  end

  def write(%__MODULE__{} = png, path) do
    data = encode(png) |> BinaryHelpers.from_list()
    File.write(path, data)
  end

  def print(%__MODULE__{data: data}) do
    Matrix.pretty_print(data, "%d", ", ")
  end

  def print_header(%__MODULE__{header: header}) do
    header |> Header.print() |> IO.puts()
    :ok
  end
end
