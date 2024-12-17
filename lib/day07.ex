defmodule Day07 do
  @operators %{
    add: &(&1 + &2),
    multiply: &(&1 * &2)
  }

  def concat(integer_1, integer_2) do
    String.to_integer("#{integer_1}#{integer_2}")
  end

  def part_one() do
    input = get_input()

    # Just take the first tuple from the input as an example
    Enum.reduce(input, 0, fn expression, acc ->
      {solution, numbers} = expression

      # We need length(numbers) - 1 operators for a single expression
      num_op_slots = length(numbers) - 1

      # Extract the operator keys
      operator_keys = Map.keys(@operators)

      # Generate all operator sequences of the required length
      operator_sequences = cartesian_power(operator_keys, num_op_slots)

      # Evaluate each operator sequence
      results =
        for ops_seq <- operator_sequences do
          evaluate_expression(numbers, ops_seq, @operators)
        end

      if solution in results do
        acc + solution
      else
        acc
      end
    end)
  end

  def part_two() do
    input = get_input()

    # Just take the first tuple from the input as an example
    Enum.reduce(input, 0, fn expression, acc ->
      {solution, numbers} = expression

      # We need length(numbers) - 1 operators for a single expression
      num_op_slots = length(numbers) - 1

      operators =
        Map.put(@operators, :concat, fn left, right ->
          String.to_integer("#{left}#{right}")
        end)

      # Extract the operator keys
      operator_keys = Map.keys(operators)

      # Generate all operator sequences of the required length
      operator_sequences = cartesian_power(operator_keys, num_op_slots)

      # Evaluate each operator sequence
      results =
        for ops_seq <- operator_sequences do
          evaluate_expression(numbers, ops_seq, operators)
        end

      if solution in results do
        acc + solution
      else
        acc
      end
    end)
  end

  def evaluate_expression([num | nums], ops, operators) do
    Enum.zip(nums, ops)
    |> Enum.reduce(num, fn {n, op}, acc ->
      operators[op].(acc, n)
    end)
  end

  def cartesian_power(_elements, 0), do: [[]]

  def cartesian_power(elements, n) do
    for elem <- elements,
        rest <- cartesian_power(elements, n - 1) do
      [elem | rest]
    end
  end

  defp get_input do
    # input = @test_input

    {:ok, input} = File.read("input/day07.txt")

    String.split(input, "\n", trim: true)
    |> Enum.map(fn row ->
      [solution, numbers_str] = String.split(row, ":", trim: true)
      solution = String.to_integer(solution)

      numbers =
        numbers_str
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)

      {solution, numbers}
    end)
  end
end
