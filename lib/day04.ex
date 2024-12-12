defmodule Day04 do
  @directions [:up, :down, :left, :right, :up_right, :up_left, :down_right, :down_left]

  def part_one do
    {:ok, input} = File.read("input/day04.txt")

    # create a grid
    grid = parse_to_grid(input)

    # create map
    map = parse_grid_to_map(grid)

    Enum.reduce(Enum.with_index(grid), 0, fn {row, row_index}, outer_acc ->
      Enum.reduce(Enum.with_index(row), outer_acc, fn {value, col_index}, middle_acc ->
        if value == "X" do
          Enum.reduce(@directions, middle_acc, fn direction, inner_acc ->
            mas = lookahead(map, row_index, col_index, direction)

            if mas == "MAS" do
              inner_acc + 1
            else
              inner_acc
            end
          end)
        else
          middle_acc
        end
      end)
    end)
  end

  def part_two do
    {:ok, input} = File.read("input/day04.txt")

    # create a grid
    grid = parse_to_grid(input)

    # create map
    map = parse_grid_to_map(grid)

    Enum.reduce(Enum.with_index(grid), 0, fn {row, row_index}, outer_acc ->
      Enum.reduce(Enum.with_index(row), outer_acc, fn {value, col_index}, inner_acc ->
        if value == "A" do
          # get the "X" pattern :up_left[0] to :down_right[0]
          up_left = lookahead(map, row_index, col_index, :up_left) |> String.at(0)
          down_right = lookahead(map, row_index, col_index, :down_right) |> String.at(0)

          # get the "X" pattern :up_right[0] to :down_left[0]
          up_right = lookahead(map, row_index, col_index, :up_right) |> String.at(0)
          down_left = lookahead(map, row_index, col_index, :down_left) |> String.at(0)

          # confirm strings for "MAS" or "SAM"
          left_to_right = "#{up_left}A#{down_right}"
          right_to_left = "#{up_right}A#{down_left}"

          if (left_to_right == "MAS" or left_to_right == "SAM") and
               (right_to_left == "MAS" or right_to_left == "SAM") do
            inner_acc + 1
          else
            inner_acc
          end
        else
          inner_acc
        end
      end)
    end)
  end

  defp parse_to_grid(input) do
    String.split(input, "\n")
    |> Enum.map(fn row -> String.trim(row) end)
    |> Enum.map(fn row -> String.graphemes(row) end)
  end

  defp parse_grid_to_map(grid) do
    Enum.with_index(grid)
    |> Enum.reduce(%{}, fn {row, row_index}, acc ->
      Enum.with_index(row)
      |> Enum.reduce(acc, fn {value, col_index}, acc ->
        Map.put(acc, {row_index, col_index}, value)
      end)
    end)
  end

  defp lookahead(map, x, y, :up) do
    m = Map.get(map, {x - 1, y})
    a = Map.get(map, {x - 2, y})
    s = Map.get(map, {x - 3, y})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :down) do
    m = Map.get(map, {x + 1, y})
    a = Map.get(map, {x + 2, y})
    s = Map.get(map, {x + 3, y})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :left) do
    m = Map.get(map, {x, y - 1})
    a = Map.get(map, {x, y - 2})
    s = Map.get(map, {x, y - 3})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :right) do
    m = Map.get(map, {x, y + 1})
    a = Map.get(map, {x, y + 2})
    s = Map.get(map, {x, y + 3})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :up_right) do
    m = Map.get(map, {x - 1, y + 1})
    a = Map.get(map, {x - 2, y + 2})
    s = Map.get(map, {x - 3, y + 3})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :up_left) do
    m = Map.get(map, {x - 1, y - 1})
    a = Map.get(map, {x - 2, y - 2})
    s = Map.get(map, {x - 3, y - 3})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :down_left) do
    m = Map.get(map, {x + 1, y - 1})
    a = Map.get(map, {x + 2, y - 2})
    s = Map.get(map, {x + 3, y - 3})
    "#{m}#{a}#{s}"
  end

  defp lookahead(map, x, y, :down_right) do
    m = Map.get(map, {x + 1, y + 1})
    a = Map.get(map, {x + 2, y + 2})
    s = Map.get(map, {x + 3, y + 3})
    "#{m}#{a}#{s}"
  end
end
