defmodule PngTest do
  use ExUnit.Case

  test "red pixel" do
    red_pixel = [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x02,
      0x00,
      0x00,
      0x00,
      0x90,
      0x77,
      0x53,
      0xDE,
      0x00,
      0x00,
      0x00,
      0x0C,
      0x49,
      0x44,
      0x41,
      0x54,
      0x08,
      0xD7,
      0x63,
      0xF8,
      0xCF,
      0xC0,
      0x00,
      0x00,
      0x03,
      0x01,
      0x01,
      0x00,
      0x18,
      0xDD,
      0x8D,
      0xB0,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82
    ]

    assert {:ok, png} = Png.decode(red_pixel)

    # one red pixel
    assert %{data: [[[255, 0, 0]]]} = png

    assert new_pixel = Png.encode(png)

    # compression algorithm can be slighty different
    # assert red_pixel == new_pixel

    assert {:ok, new_png} = Png.decode(new_pixel)

    assert new_png == png
  end

  test "parses pixels the correct way round" do
    assert {:ok, png} = Png.file("priv/colors.png")

    %{
      data: [
        [[0, 0, 0], [237, 28, 36], [255, 242, 0]],
        [[34, 177, 76], [127, 127, 127], [163, 73, 164]],
        [[0, 162, 232], [255, 174, 201], [255, 255, 255]]
      ]
    } = png
  end

  describe "write tests" do
    test "multi data parts" do
      assert {:ok, png} = Png.file("priv/multi_data.png")

      {:ok, path} = Briefly.create(directory: true)

      assert :ok = Png.write(png, "#{path}/multi_data.png")
      assert {:ok, new_png} = Png.file("#{path}/multi_data.png")

      # assert png.extra == new_png.extra
    end
  end
end
