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
  |> Enum.each(fn file_path ->
    @file_path file_path
    test "sanity #{@file_path} test" do
      assert {:ok, png} = Png.file("#{@image_dir}/#{@file_path}")
    end
  end)
end
