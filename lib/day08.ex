defmodule Day08 do
  ################
  # public methods
  ################
  def part_one, do: run(:one)
  def part_two, do: run(:two)

  #################
  # private methods
  #################
  defp run(part) do
    input = get_input()
    grid = parse_grid()
    grid_dimension = grid_dimensions(input)

    case part do
      :one -> count_antinodes(grid, grid_dimension, &find_antinodes/2)
      :two -> count_antinodes(grid, grid_dimension, &find_antinodes_any/2)
    end
  end

  defp count_antinodes(grid, grid_dimension, finder_function) do
    Task.async_stream(grid, fn {_key, positions} ->
      finder_function.(grid_dimension, positions)
    end)
    |> Enum.reduce([], fn {:ok, positions}, acc -> positions ++ acc end)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp next_position(position_1, position_2) do
    {column_1, row_1} = position_1
    {column_2, row_2} = position_2

    {column_2 + (column_2 - column_1), row_2 + (row_2 - row_1)}
  end

  defp find_antinodes(grid_dimension, positions) do
    Enum.with_index(positions)
    |> Enum.flat_map(fn {_position, i} ->
      {current_position, remaining} = List.pop_at(positions, i)

      Enum.flat_map(remaining, fn other_position ->
        position_1 = next_position(current_position, other_position)
        position_2 = next_position(other_position, current_position)

        Enum.reject([position_1, position_2], &position_outside?(&1, grid_dimension))
      end)
    end)
  end

  defp find_antinodes_any(grid, positions) do
    Enum.with_index(positions)
    |> Enum.flat_map(fn {_position, index} ->
      {current_position, remaining} = List.pop_at(positions, index)

      Enum.flat_map(remaining, fn other_position ->
        generate_antinodes(grid, other_position, current_position, []) ++
          generate_antinodes(grid, other_position, current_position, [])
      end)
    end)
  end

  defp generate_antinodes(grid_dimension, current_position, next_pos, acc) do
    if position_outside?(next_pos, grid_dimension) do
      acc
    else
      new_next_pos = next_position(current_position, next_pos)
      generate_antinodes(grid_dimension, next_pos, new_next_pos, [next_pos | acc])
    end
  end

  defp grid_dimensions(input) do
    lines = String.split(input, "\n", trim: true)
    row_count = length(lines)
    col_count = hd(lines) |> String.length()
    {col_count, row_count}
  end

  defp position_outside?({column, row} = _position, {column_count, row_count} = _grid_dimension) do
    column >= column_count or column < 0 or row >= row_count or row < 0
  end

  #########################
  # input and input parsing
  #########################
  defp get_input do
    {:ok, input} = File.read("input/day08.txt")
    input
  end

  defp parse_grid do
    get_input()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.flat_map(fn
        {".", _column} -> []
        {char, column} -> [{char, {column, row}}]
      end)
    end)
    |> Enum.group_by(
      fn {char, _position} -> char end,
      fn {_char, position} -> position end
    )
  end
end
