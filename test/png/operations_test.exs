defmodule Png.OperationsTest do
  use ExUnit.Case

  @sample_png %Png{
    data: [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
  }

  test "at" do
    assert 5 == Png.Operations.at(@sample_png, 1, 1)
    assert 6 == Png.Operations.at(@sample_png, 1, 2)
    assert 7 == Png.Operations.at(@sample_png, 2, 0)
    assert is_nil(Png.Operations.at(@sample_png, 9, 6))
    assert :testing == Png.Operations.at(@sample_png, 9, 6, :testing)
  end

  test "fetch" do
    assert {:ok, 5} == Png.Operations.fetch(@sample_png, 1, 1)
    assert {:ok, 6} == Png.Operations.fetch(@sample_png, 1, 2)
    assert {:ok, 7} == Png.Operations.fetch(@sample_png, 2, 0)
    assert :error == Png.Operations.fetch(@sample_png, 9, 6)
  end

  describe "slice" do
    test "success" do
      assert [[1, 2], [4, 5]] == Png.Operations.slice(@sample_png, 0..1, 0..1)
    end

    test "miss" do
      assert [[], []] == Png.Operations.slice(@sample_png, 0..1, 5..9)
    end

    test "invalid arguments" do
      assert_raise(ArgumentError, fn -> Png.Operations.slice(@sample_png, 1, 5..9) end)
    end
  end
end
