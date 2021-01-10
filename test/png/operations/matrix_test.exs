defmodule Png.Operations.MatrixTest do
  use ExUnit.Case

  alias Png.Operations.Matrix

  test "empty?" do
    assert Matrix.empty?([])
    assert Matrix.empty?([[], []])
  end

  describe "slice" do
    setup do
      %{
        data: [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9]
        ]
      }
    end

    test "success", %{data: data} do
      assert [[1, 2], [4, 5]] == Matrix.slice(data, 0..1, 0..1)
      assert [[1, 2, 3], [4, 5, 6]] == Matrix.slice(data, 0..1, 0..2)
      assert [[1, 2], [4, 5], [7, 8]] == Matrix.slice(data, 0..2, 0..1)
    end

    test "miss", %{data: data} do
      assert [] == Matrix.slice(data, 5..9, 0..1)
      assert [[], []] == Matrix.slice(data, 0..1, 5..9)
    end

    test "invalid arguments", %{data: data} do
      assert_raise(ArgumentError, fn -> Matrix.slice(data, 1, 5..9) end)
    end
  end

  test "chunk" do
    five_by_five = [
      [11, 12, 13, 14, 15],
      [16, 17, 18, 19, 20],
      [21, 22, 23, 24, 25],
      [26, 27, 28, 29, 30],
      [31, 32, 33, 34, 35]
    ]

    assert [
             {[11, 12], [16, 17]},
             {[13, 14], [18, 19]},
             {[15], [20]},
             {[21, 22], [26, 27]},
             {[23, 24], [28, 29]},
             {[25], [30]},
             {[31, 32], []},
             {[33, 34], []},
             {[35], []}
           ] == Matrix.chunk(five_by_five, 2, 2)

    assert [
             {[11, 12], [16, 17], [21, 22]},
             {[13, 14], [18, 19], [23, 24]},
             {[15], [20], [25]},
             {[26, 27], [31, 32], []},
             {[28, 29], [33, 34], []},
             {[30], [35], []}
           ] == Matrix.chunk(five_by_five, 3, 2)

    assert [
             {[11, 12, 13], [16, 17, 18]},
             {[14, 15], [19, 20]},
             {[21, 22, 23], [26, 27, 28]},
             {[24, 25], [29, 30]},
             {[31, 32, 33], []},
             {[34, 35], []}
           ] == Matrix.chunk(five_by_five, 2, 3) |> IO.inspect(charlists: :as_lists)
  end
end
