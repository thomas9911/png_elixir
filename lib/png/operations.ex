defmodule Png.Operations do
  @moduledoc """
  Operations on Png struct
  """

  alias Png.Operations.Matrix

  @argument_error_message "First argument should be %Png{}"

  def at(png, x, y, default \\ nil)

  def at(%Png{data: data}, x, y, default) do
    Matrix.elem(data, x, y, default)
  end

  def at(_, _, _, _), do: argument_error()

  def fetch(%Png{} = png, x, y) do
    ref = make_ref()

    case at(png, x, y, ref) do
      ^ref -> :error
      item -> {:ok, item}
    end
  end

  def fetch(_, _, _), do: argument_error()

  def fetch!(%Png{} = png, x, y) do
    {:ok, item} = fetch(png, x, y)
    item
  end

  def fetch!(_, _, _), do: argument_error()

  def slice(%Png{data: data} = _png, rows, cols) do
    Matrix.slice(data, rows, cols)
  end

  def slice(_, %Range{} = _, %Range{} = _), do: argument_error()

  defp argument_error(msg \\ @argument_error_message) do
    raise(ArgumentError, message: msg)
  end
end
