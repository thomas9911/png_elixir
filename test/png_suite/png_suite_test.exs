defmodule PngSuiteTest do
  use ExUnit.Case

  @image_dir "#{__DIR__}/PngSuite"

  invalid_png? = fn
    "x" <> _ -> true
    path -> !String.ends_with?(path, ".png")
  end

  @image_dir
  |> File.ls!()
  |> Enum.reject(invalid_png?)
  |> Enum.filter(&(&1 == "basi2c08.png"))
  |> Enum.each(fn file_path ->
    @file_path file_path
    test "sanity #{@file_path} test" do
      assert {:ok, png} = Png.file("#{@image_dir}/#{@file_path}")
      png |> Png.print_header()
      assert {:ok, png2} = Png.file("interlace_test.png")

      assert png.data == png2.data
      # png = put_in(png, [:headers, :interlace_method], 0)
      # header = png.header |> Map.put(:interlace_method, 0)
      # png = %{png | header: header}
      # Png.write(png, "interlace_test.png")
      # assert {:ok, png} = Png.file("interlace_test.png")
    end
  end)
end
