defmodule Png.Chunk.Header do
  defstruct [
    :width,
    :height,
    :depth,
    :color_type,
    :compression_method,
    :filter_method,
    :interlace_method
  ]

  alias Png.BinaryHelpers

  #   pub struct Header {
  #     pub width: u32,
  #     pub height: u32,
  #     // the number of bits per sample or per palette index (not per pixel)
  #     pub depth: u8,
  #     pub color_type: Color,
  #     pub compression_method: u8,
  #     pub filter_method: u8,
  #     pub interlace_method: u8,
  # }

  @behaviour Png.Chunk

  defguard is_valid(chunk)
           when is_integer(:erlang.map_get(:width, chunk)) and
                  is_integer(:erlang.map_get(:height, chunk)) and
                  is_integer(:erlang.map_get(:depth, chunk)) and
                  is_integer(:erlang.map_get(:color_type, chunk)) and
                  is_integer(:erlang.map_get(:compression_method, chunk)) and
                  is_integer(:erlang.map_get(:filter_method, chunk)) and
                  is_integer(:erlang.map_get(:interlace_method, chunk))

  @impl true
  def parse(%{data: chunk_data}, _) do
    # %__MODULE__{raw: chunk_data}
    do_parse({chunk_data, %__MODULE__{}})
  end

  defp do_parse({_bytes, header}) when is_valid(header) do
    header
  end

  defp do_parse({[a, b, c, d | rest], %{width: nil} = header}) do
    width = BinaryHelpers.to_uint(<<a, b, c, d>>)
    do_parse({rest, %{header | width: width}})
  end

  defp do_parse({[a, b, c, d | rest], %{height: nil} = header}) do
    height = BinaryHelpers.to_uint(<<a, b, c, d>>)
    do_parse({rest, %{header | height: height}})
  end

  defp do_parse({[a | rest], %{depth: nil} = header}) do
    depth = BinaryHelpers.to_uint(<<a>>)
    do_parse({rest, %{header | depth: depth}})
  end

  defp do_parse({[a | rest], %{color_type: nil} = header}) do
    color_type = BinaryHelpers.to_uint(<<a>>)
    do_parse({rest, %{header | color_type: color_type}})
  end

  defp do_parse({[a | rest], %{compression_method: nil} = header}) do
    compression_method = BinaryHelpers.to_uint(<<a>>)
    do_parse({rest, %{header | compression_method: compression_method}})
  end

  defp do_parse({[a | rest], %{filter_method: nil} = header}) do
    filter_method = BinaryHelpers.to_uint(<<a>>)
    do_parse({rest, %{header | filter_method: filter_method}})
  end

  defp do_parse({[a | rest], %{interlace_method: nil} = header}) do
    interlace_method = BinaryHelpers.to_uint(<<a>>)
    do_parse({rest, %{header | interlace_method: interlace_method}})
  end

  @impl true
  def parameter(), do: {:struct, :header}

  def to_chunk_data(%__MODULE__{
        width: width,
        height: height,
        depth: depth,
        color_type: color_type,
        compression_method: compression_method,
        filter_method: filter_method,
        interlace_method: interlace_method
      }) do
    [
      BinaryHelpers.from_uint(width, 4),
      BinaryHelpers.from_uint(height, 4),
      BinaryHelpers.from_uint(depth, 1),
      BinaryHelpers.from_uint(color_type, 1),
      BinaryHelpers.from_uint(compression_method, 1),
      BinaryHelpers.from_uint(filter_method, 1),
      BinaryHelpers.from_uint(interlace_method, 1)
    ]
    |> Enum.join()
    |> BinaryHelpers.to_list()
  end

  def print(%__MODULE__{
        width: width,
        height: height,
        depth: depth,
        color_type: color_type,
        compression_method: compression_method,
        filter_method: filter_method,
        interlace_method: interlace_method
      }) do
    Enum.join(
      [
        printer(:width, width),
        printer(:height, height),
        printer(:depth, depth),
        printer(:color_type, color_type),
        printer(:compression_method, compression_method),
        printer(:filter_method, filter_method),
        printer(:interlace_method, interlace_method)
      ],
      "\n"
    )
  rescue
    FunctionClauseError ->
      "invalid meta data\nUse IO.inspect(png.header) to check the meta data"
  end

  defp printer(:width, width), do: "width: #{width} pixels"
  defp printer(:height, height), do: "height: #{height} pixels"
  defp printer(:depth, 1), do: "bit depth: 1 bit"
  defp printer(:depth, depth), do: "bit depth: #{depth} bits"
  defp printer(:color_type, 0), do: "color type: Grayscale"
  defp printer(:color_type, 2), do: "color type: RGB"
  defp printer(:color_type, 3), do: "color type: Indexed"
  defp printer(:color_type, 4), do: "color type: Grayscale + Alpha"
  defp printer(:color_type, 6), do: "color type: RGBA"

  defp printer(:compression_method, 0),
    do: "compression method: deflate/inflate compression with a 32K sliding window"

  defp printer(:filter_method, 0), do: "filter method: None"
  defp printer(:filter_method, 1), do: "filter method: Sub"
  defp printer(:filter_method, 2), do: "filter method: Up"
  defp printer(:filter_method, 3), do: "filter method: Average"
  defp printer(:filter_method, 4), do: "filter method: Paeth"
  defp printer(:interlace_method, 0), do: "interlace method: None"
  defp printer(:interlace_method, 1), do: "interlace method: Adam7"
end
