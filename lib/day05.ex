defmodule Day05 do
  def part_one do
    {rules, pages} = get_input()

    pages
    |> Enum.filter(&page_valid?(&1, rules))
    |> Enum.map(&get_middle_page_number/1)
    |> Enum.sum()
  end

  defp get_middle_page_number(page) do
    Enum.at(page, div(length(page), 2))
  end

  defp page_valid?(page, rules_map) do
    Enum.with_index(page)
    |> Enum.all?(fn {current_element, index} ->
      rules = Map.get(rules_map, current_element, [])
      rules == [] or no_rule_violations?(rules, page, index)
    end)
  end

  defp no_rule_violations?(rules, page, index) do
    required_prior_rules = rules |> Enum.map(&elem(&1, 0)) |> MapSet.new()
    remaining_rules = page |> Enum.drop(index + 1) |> MapSet.new()

    MapSet.disjoint?(required_prior_rules, remaining_rules)
  end

  defp get_input() do
    {:ok, input} = File.read("input/day05.txt")

    [rules_input | [pages_input | _]] = String.split(input, "\n\n", trim: true)

    rules =
      String.split(rules_input, "\n", trim: true)
      |> Enum.map(fn rule ->
        rule
        |> String.split("|")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.group_by(&elem(&1, 1))

    pages =
      String.split(pages_input, "\n", trim: true)
      |> Enum.map(fn page ->
        page
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    {rules, pages}
  end
end
