defmodule Png.Operations.Matrix do
  @moduledoc """
  Wrapper around `Matrix` library plus some extra functions
  """

  use Wrapper, [Matrix]

  def slice(data, %Range{} = rows, %Range{} = cols) do
    data
    |> Enum.slice(rows)
    |> Enum.map(fn row ->
      Enum.slice(row, cols)
    end)
  end

  def slice(_, b, c) do
    raise(ArgumentError,
      message: "Second and Third argument should be ranges got #{inspect(b)} and #{inspect(c)}"
    )
  end

  def empty?(data), do: Enum.all?(data, &Enum.empty?/1)

  def chunk(data, rows, columns) do
    Enum.map(data, fn column ->
      Enum.chunk_every(column, columns)
    end)
    |> Enum.chunk_every(rows)
    |> Enum.flat_map(&chunk_zipper(&1, rows))
  end

  defp chunk_zipper(data, rows) do
    data_length = Enum.count(data)

    data =
      unless data_length == rows do
        padding_amount = rows - data_length

        chunks_amount =
          data
          |> List.first()
          |> Enum.count()

        empty_row = List.duplicate([], chunks_amount)
        Enum.concat(data, List.duplicate(empty_row, padding_amount))
      else
        data
      end

    Enum.zip(data)
  end
end
