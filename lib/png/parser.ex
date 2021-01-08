defmodule Png.Parser do
  @signature [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

  @doc """
    parses png data into chunks

    Red dot example from wikipedia:
    ```elixir
    iex> red_dot = [
    ...>     0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48,
    ...>     0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x02, 0x00, 0x00,
    ...>     0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54, 0x08,
    ...>     0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00, 0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D,
    ...>     0xB0, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ...> ]
    iex> Png.Parser.parse(red_dot)
    {:ok,
     [
       %Png.Chunk{
         crc: 2_423_739_358,
         data: [0, 0, 0, 1, 0, 0, 0, 1, 8, 2, 0, 0, 0],
         len: 13,
         type: "IHDR"
       },
       %Png.Chunk{
         crc: 417_172_912,
         data: [8, 215, 99, 248, 207, 192, 0, 0, 3, 1, 1, 0],
         len: 12,
         type: "IDAT"
       },
       %Png.Chunk{crc: 2_923_585_666, data: [], len: 0, type: "IEND"}
     ]}
    ```

  """
  @spec parse(list) :: {:ok, [Png.Chunk.t()]} | {:error, atom}
  def parse(@signature ++ rest = _input) do
    do_parse(rest, [])
  end

  def parse(_) do
    {:error, :invalid_signature}
  end

  def do_parse([], acc) do
    {:ok, :lists.reverse(acc)}
  end

  def do_parse(input, acc) do
    case Png.Chunk.parse(input) do
      {:ok, chunk, rest} ->
        do_parse(rest, [chunk | acc])

      {:error, error} ->
        {:error, error}
    end
  end
end
