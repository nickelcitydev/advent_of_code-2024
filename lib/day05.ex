defmodule Day05 do
  def part_one do
    {rules, pages} = get_input()

    rules_map =
      rules
      |> Enum.group_by(&elem(&1, 1))

    pages
    |> Enum.filter(&page_valid?(&1, rules_map))
    |> Enum.map(&get_middle_page_number/1)
    |> Enum.sum()
  end

  def part_two do
    {rules, pages} = get_input()

    rules_map =
      rules
      |> Enum.group_by(&elem(&1, 1))

    pages
    |> Enum.map(fn page ->
      if page_valid?(page, rules_map) do
        0
      else
        page
        |> rule_sort(rules)
        |> get_middle_page_number()
      end
    end)
    |> Enum.sum()
  end

  defp rule_sort(page_elements, all_rules) do
    Enum.sort(page_elements, &compare_by_rules(&1, &2, all_rules))
  end

  defp compare_by_rules(a, b, rules) do
    cond do
      Enum.member?(rules, {a, b}) -> true
      Enum.member?(rules, {b, a}) -> false
      true -> a < b
    end
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
