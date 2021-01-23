defmodule AdventOfCode.Day21 do
  def part1(args) do
    # Parse le fichier d'entrée
    raw = parse(args)

    # Trouve une solution, c'est à dire une liste de correspondances {allergene, ingredient}
    # Crée une Map( allergene => liste de tous les MapSet d'ingredients dans lequel il pourrait être)
    sol =
      build_allergens_set(raw)
      # Trouve la liste de corresponcance {allergene,  ingredient}
      |> solve()
      # Garde uniquement les aliments
      |> Enum.map(&elem(&1, 1))

    # Compte les ingredients dont on n'a pas trouvé l'allergene
    raw
    # ne garde que les ingredients
    |> Enum.map(&elem(&1, 0))
    # transforme le MapSet en List
    |> Enum.map(&MapSet.to_list/1)
    # Obtient une seule longue liste de tous les ingredients
    |> List.flatten()
    # Enlève ceux dont on a trouvé l'allergene
    |> Enum.filter(fn i -> not Enum.member?(sol, i) end)
    |> Enum.count()
  end

  def part2(args) do
    # Parse le fichier d'entrée
    raw = parse(args)

    build_allergens_set(raw)
    # Trouve la liste de corresponcance {allergene,  ingredient}
    |> solve()
    # Trie par ordre alpha des allergenes
    |> Enum.sort(fn {a1, _}, {a2, _} -> a1 < a2 end)
    # Garde uniquement les aliments
    |> Enum.map(&elem(&1, 1))
    # Trie par ordre alpha
    |> Enum.join(",")
  end

  def build_allergens_set(raw), do: build_allergens_set(raw, %{})

  def build_allergens_set([], a_set), do: a_set |> Map.to_list()

  def build_allergens_set([{ingredients, allergens} | rest], a_set) do
    build_allergens_set(
      rest,
      Enum.reduce(allergens, a_set, fn a, acc ->
        Map.update(acc, a, [ingredients], fn l -> [ingredients | l] end)
      end)
    )
  end

  defp solve(raw), do: solve(raw, [])

  defp solve([], sol), do: sol

  defp solve([{allergen, ing_lists} | rest], sol) do
    # Considère le premier allergene
    # Fait l'intersection de toutes les listes d'ingredients dans lesquelles il apparait
    intersect = ing_lists |> Enum.reduce(fn s1, acc -> MapSet.intersection(s1, acc) end)

    # Est-ce un singleton ?
    if Enum.count(intersect) > 1 do
      # Recommence en mettant l'allergene à la fin de la liste
      solve(rest ++ [{allergen, ing_lists}], sol)
    else
      # C'est un singleton, donc on a trouvé une solution {allergen, ingredient}
      [ingredient] = intersect |> MapSet.to_list()
      # Nettoie toutes les listes d'ingredients de l'ingredient que l'on vient de trouver
      # avec l'espoir que de nouveaux singletons se créent
      new_rest =
        rest
        |> Enum.map(fn {a, i_list} ->
          {a, Enum.map(i_list, fn l -> MapSet.delete(l, ingredient) end)}
        end)

      # continue avec le reste de la liste
      solve(new_rest, [{allergen, ingredient} | sol])
    end
  end

  defp parse_line(line) do
    [ingredients, allergens] = line |> String.split("(contains ", time: true)
    ingredients = ingredients |> String.split(" ", trim: true)
    allergens = allergens |> String.slice(0..-2) |> String.split(", ", trim: true)
    {ingredients |> MapSet.new(), allergens}
  end

  # A partir du fichier d'entrée
  # Renvoie une liste de { MapSet des ingredients, liste des allergenes}
  defp parse(input) do
    raw =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)

    # ingredients = raw |> Enum.map(&elem(&1, 0)) |> List.flatten() |> MapSet.new()
    # allergens = raw |> Enum.map(&elem(&1, 1)) |> List.flatten() |> MapSet.new()
    # {raw, ingredients, allergens}
  end
end
