defmodule Day06 do
  def part_one do
    grid = get_input()

    guard_position = find_position_of_char(grid, "^")
    grid = update_cell(grid, guard_position, ".")

    initial_direction = {0, -1}
    visited_positions = [guard_position]

    count_unique_visited_cells(grid, guard_position, initial_direction, visited_positions)
  end

  def part_two do
    grid = get_input()

    guard_position = find_position_of_char(grid, "^")
    grid = update_cell(grid, guard_position, ".")

    row_count = Map.keys(grid) |> length()
    column_count = Map.get(grid, 0) |> Map.keys() |> length()

    candidate_positions =
      0..(row_count - 1)
      |> Enum.flat_map(fn row ->
        0..(column_count - 1) |> Enum.map(fn col -> {col, row} end)
      end)
      |> Enum.filter(fn position ->
        cell_at(grid, position) != "#" and position != guard_position
      end)

    candidate_positions
    |> Task.async_stream(fn pos ->
      update_cell(grid, pos, "#")
      |> detect_guard_loop?(guard_position, {0, -1})
    end)
    |> Enum.map(fn {:ok, result} -> result end)
    |> Enum.sum()
  end

  def detect_guard_loop?(grid, current_position, direction, visited \\ []) do
    facing_position = forward_position(direction, current_position)
    facing_cell_value = cell_at(grid, facing_position)

    cond do
      {current_position, direction} in visited ->
        1

      facing_cell_value == "#" ->
        detect_guard_loop?(grid, current_position, rotate_direction_90(direction), [
          {current_position, direction} | visited
        ])

      facing_cell_value == "." ->
        detect_guard_loop?(grid, facing_position, direction, [
          {current_position, direction} | visited
        ])

      true ->
        0
    end
  end

  defp cell_at(grid, {col, row}) do
    get_in(grid, [row, col]) || ""
  end

  defp count_unique_visited_cells(grid, current_pos, direction, visited) do
    next_pos = forward_position(current_pos, direction)
    cell_value = cell_at(grid, next_pos)

    cond do
      cell_value == "" ->
        visited
        |> Enum.uniq()
        |> length()

      cell_value == "." ->
        count_unique_visited_cells(grid, next_pos, direction, [next_pos | visited])

      cell_value == "#" ->
        # Rotate direction and try again from the same current position
        new_direction = rotate_direction_90(direction)
        count_unique_visited_cells(grid, current_pos, new_direction, visited)
    end
  end

  defp get_input do
    {:ok, input} = File.read("input/day06.txt")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row_to_map/1)
    |> Enum.with_index()
    |> Enum.map(fn {row_map, row_index} -> {row_index, row_map} end)
    |> Map.new()
  end

  defp find_position_of_char(grid, char) do
    Enum.reduce_while(grid, nil, fn {row_index, row_map}, _acc ->
      case Enum.find(row_map, fn {_col_index, cell} -> cell == char end) do
        {col_index, _cell} -> {:halt, {col_index, row_index}}
        nil -> {:cont, nil}
      end
    end)
  end

  defp forward_position({col, row}, {dc, dr}), do: {col + dc, row + dr}

  defp rotate_direction_90({0, -1}), do: {1, 0}
  defp rotate_direction_90({1, 0}), do: {0, 1}
  defp rotate_direction_90({0, 1}), do: {-1, 0}
  defp rotate_direction_90({-1, 0}), do: {0, -1}

  defp parse_row_to_map(row) do
    row
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.map(fn {char, col_index} -> {col_index, char} end)
    |> Map.new()
  end

  defp update_cell(grid, {col, row}, value) do
    Map.update!(grid, row, fn r -> Map.put(r, col, value) end)
  end
end
