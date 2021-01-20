defmodule AdventOfCode.Day20 do
  def part1(args) do
    {sol, square_size} = compute_solution(args)

    # Calcule le produit des id des 4 coins
    h = square_size - 1

    Enum.map([{0, 0}, {0, h}, {h, 0}, {h, h}], fn
      c ->
        {n, _} = sol[c]
        n
    end)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def compute_solution(args) do
    # Prepare les tuiles à partir du fichier d'entrée: créé toutes les combinaisons de rotations/symétries
    # Analyse le fichier
    tiles =
      parse(args)
      |> Enum.map(fn {number, tile} -> {number, process_tile(tile, true)} end)

    # Récupère tous les côtés de toutes les combinaisons de rotations symétries et en calcule les fréquences
    all_numbers =
      tiles
      |> Enum.map(fn {_, x} -> x end)
      |> List.flatten()
      |> Enum.map(&Tuple.to_list/1)
      |> List.flatten()
      |> Enum.frequencies()

    # Trouve un score par tuile en ajoutant les fréquences des 4 côtés
    rank =
      tiles
      |> Enum.map(fn {number, tile} ->
        {number,
         hd(tile) |> Tuple.to_list() |> Enum.reduce(0, fn x, acc -> acc + all_numbers[x] end)}
      end)
      |> Map.new()

    # Calcule la taille du pavage total (racine carrée du nombre de tuiles)
    square_size = :math.sqrt(Enum.count(tiles)) |> trunc()

    # Crée une liste "flat" de toutes les combinaisons de rotations/symétrie
    # Chaque élément de la liste est {id de la tuile, {4 cotés}}
    flat_tiles =
      tiles
      |> Enum.map(fn {number, tile} ->
        for comb <- tile, do: {number, comb}
      end)
      |> List.flatten()
      # Trie cette liste par ordre croissant des "rank". Du coup, on trouve les coins d'abord, puis les bords, puis les tuiles du milieu
      |> Enum.sort(fn {n1, _}, {n2, _} -> rank[n1] < rank[n2] end)

    # Calcul récursif de la solution
    {find_solution(%{}, square_size, {0, 0}, flat_tiles), square_size}
  end

  def part2(args) do
    # récupère les images des tuiles avec toutes leurs combinaisons
    tiles =
      parse(args)
      |> Enum.map(fn {number, tile} -> {number, process_tile(tile, false) |> Map.new()} end)
      |> Map.new()

    # Trouve un pavage solution
    {sol, square_size} = compute_solution(args)
    h = square_size - 1
    # Enlève le "tour" de chaque tuile du pavage solution
    tiled_sol =
      sol
      |> Enum.map(fn {cell, {tile, comb}} -> {cell, trim_matrix(tiles[tile][comb])} end)
      |> Map.new()

    line_per_tile = Enum.count(tiled_sol[{0, 0}])
    # Crée une image résultante en mettant bout à bout toutes les tuiles
    image =
      for r <- 0..(square_size * line_per_tile - 1),
          do:
            Enum.join(
              for c <- 0..h,
                  do: Enum.at(tiled_sol[{div(r, line_per_tile), c}], rem(r, line_per_tile))
            )

    # Genère une liste de toutes les combinaisons/symétries
    core = image |> Enum.map(&String.graphemes/1)
    flip_h = fliph(core)
    flip_v = flipv(core)

    # Identifie les monstres marins dans l'image
    {snakes, in_image} =
      (produce_rotations(core) ++ produce_rotations(flip_h) ++ produce_rotations(flip_v))
      |> Enum.map(fn tile -> to_str(tile) end)
      |> Enum.map(fn image -> {identify_snake(image), image} end)
      |> Enum.filter(fn {l, _image} -> not Enum.empty?(l) end)
      |> hd()

    # Met des "0" à la place des monstres détectés, puis somme les "1"
    Enum.reduce(snakes, in_image, fn {r, c}, im -> set_deltarcs(im, r, c, snake(), "0") end)
    |> Enum.map(&String.graphemes/1)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp identify_snake(image) do
    # Taille de l'image
    {h_image, w_image} = {Enum.count(image), String.length(hd(image))}
    s = snake()
    # Taille du monstre marin
    {h_snake, w_snake} =
      {Enum.max(Enum.map(s, fn x -> elem(x, 0) end)),
       Enum.max(Enum.map(s, fn x -> elem(x, 1) end))}

    full_snake = String.duplicate("1", Enum.count(s))
    # Boucle sur toutes les positions possibles du serpent et garde les "matchs"
    for(r <- 0..(h_image - h_snake - 1), c <- 0..(w_image - w_snake - 1), do: {r, c})
    |> Enum.filter(fn {r, c} -> get_snake(image, r, c) == full_snake end)
  end

  # Coeur de l'algorithme
  # C'est une force brute qui essaie toutes les combinaisons en commençant en haut à gauche et par balayage
  # L'idée est de considérer à égalité toutes les combinaisons de rotations/symétries de chaque tuile
  # Par exemple, s'il y a 9 tuiles commme dans l'exemple, "tiles" est une liste de 9 * 12 possibilités
  # pavage  = Map { {row, colum} => {tuile id, {t,b,l,r}}}
  # square_size = côté du pavage
  # {row, col} = cellule du pavage à remplir. pavage doit être rempli de toutes les tuiles précédentes
  # tiles = voir ci dessus
  def find_solution(pavage, square_size, {row, col}, tiles) do
    # si tout le pavage est rempli, alors on a trouvé une solution
    if row == square_size do
      pavage
    else
      # Sinon, considérons le carreau (tile) au dessus et le carreau à gauche de la position courante, s'ils existent
      {up, left} = {pavage[{row - 1, col}], pavage[{row, col - 1}]}

      # Liste les tuiles qui obeissent aux contraintes (celle dont le bord gauche = le bord droit de la tuile de gauche et dont le bord haut = le bord bas de la tuile du dessus)
      filtered_tiles =
        tiles
        |> Enum.filter(fn {_number, {t, _b, l, _r}} ->
          cond_1 =
            if up do
              {_number, {_t, b, _l, _r}} = up
              t == b
            else
              true
            end

          cond_2 =
            if left do
              {_number, {_t, _b, _l, r}} = left
              l == r
            else
              true
            end

          cond_1 and cond_2
        end)

      if Enum.empty?(filtered_tiles) do
        # Si l'on n'a pas de possibilités, c'est qu'on a fait choux blanc. On revient d'un cran dans la récursivité
        nil
      else
        # Prochaine cellule du pavage à considérer
        next_cell = if col == square_size - 1, do: {row + 1, 0}, else: {row, col + 1}

        # On va essayer une par une toutes les tuiles/comboinaisons possible jusqu'à en trouver une qui marche
        filtered_tiles
        |> Enum.reduce_while(
          # ne sert à rien; C'est un While pur et pas un reduce
          0,
          fn {number, _} = tile, _acc ->
            # On enlève de la liste des tuiles celle qu'on va poser (tile)
            tiles_without_current_tile = tiles |> Enum.filter(fn {n, _} -> n != number end)

            # La récursivité : on appelle la fonction avec un pavage sur lequel on a posé la tuile en cours (tile), en lui demandant de considérer la cellule
            # suivante, avec une liste de tuile nettoyée de la tuile posée
            res =
              find_solution(
                Map.put(pavage, {row, col}, tile),
                square_size,
                next_cell,
                tiles_without_current_tile
              )

            if res == nil, do: {:cont, nil}, else: {:halt, res}
          end
        )
      end
    end
  end

  defp snake do
    [
      {0, 18},
      {1, 0},
      {1, 5},
      {1, 6},
      {1, 11},
      {1, 12},
      {1, 17},
      {1, 18},
      {1, 19},
      {2, 1},
      {2, 4},
      {2, 7},
      {2, 10},
      {2, 13},
      {2, 16}
    ]
  end

  # Enlève le "tour" d'une matrice
  def trim_matrix(matrix) do
    matrix |> Enum.slice(1..-2) |> Enum.map(fn s -> String.slice(s, 1..-2) end)
  end

  # Plein de fonctions pour manier les matrices
  defp get_snake(matrix, r, c) do
    get_deltarc(matrix, r, c, snake()) |> Enum.join()
  end

  def get_deltarc(matrix, r, c, l) do
    get_rcs(matrix, Enum.map(l, fn {rl, cl} -> {rl + r, cl + c} end))
  end

  defp get_rc(matrix, r, c) do
    Enum.at(matrix, r) |> String.at(c)
  end

  defp get_rcs(matrix, l) do
    Enum.map(l, fn {r, c} -> get_rc(matrix, r, c) end)
  end

  defp set_deltarcs(matrix, r, c, l, v) do
    set_rcs(matrix, Enum.map(l, fn {rl, cl} -> {rl + r, cl + c} end), v)
  end

  defp set_rcs(matrix, l, v) do
    Enum.reduce(l, matrix, fn {r, c}, acc -> set_rc(acc, r, c, v) end)
  end

  defp set_rc(matrix, r, c, v) do
    List.update_at(matrix, r, fn row ->
      if c == 0 do
        s_after = String.slice(row, 1..-1)
        "#{v}#{s_after}"
      else
        s_before = String.slice(row, 0..(c - 1))
        s_after = String.slice(row, (c + 1)..-1)
        "#{s_before}#{v}#{s_after}"
      end
    end)
  end

  # Rotation de 90 degrés dans le sens des aiguilles d'une montre
  defp rotate90(matrix) do
    size = Enum.count(matrix) - 1

    Enum.map(0..size, fn l ->
      for(r <- 0..size, do: matrix |> Enum.at(r) |> Enum.at(l)) |> Enum.reverse()
    end)
  end

  # Symétrie 1
  defp flipv(matrix) do
    matrix |> Enum.map(fn l -> Enum.reverse(l) end)
  end

  # Symétrie 2
  defp fliph(matrix) do
    Enum.reverse(matrix)
  end

  defp produce_rotations(matrix) do
    matrix90 = rotate90(matrix)
    matrix180 = rotate90(matrix90)
    matrix270 = rotate90(matrix180)
    [matrix, matrix90, matrix180, matrix270]
  end

  # Important : pour accélérer le traitement, je ne garde que les côtés d'une tuile (top, bottom, left, right)
  # Et surtout je transforme les chaines de caractères en un nombre entier en supposant que le # sont des 1 et les . des 0
  # j'ai transformé au tout début les # et les .
  defp to_tblr(tile) do
    {top, bottom, left, right} = {
      List.first(tile),
      List.last(tile),
      for(line <- tile, do: String.first(line)) |> Enum.join(),
      for(line <- tile, do: String.last(line)) |> Enum.join()
    }

    {String.to_integer(top, 2), String.to_integer(bottom, 2), String.to_integer(left, 2),
     String.to_integer(right, 2)}
  end

  defp to_str(tile) do
    Enum.map(tile, &Enum.join/1)
  end

  # A partir d'une tuile, produit toutes les rotations/symétries et, éventuellement, extrait les côtés en les codant en integer
  defp process_tile(tile, tblr_only) do
    core = tile |> Enum.map(&String.graphemes/1)
    flip_h = fliph(core)
    flip_v = flipv(core)

    combinations =
      (produce_rotations(core) ++ produce_rotations(flip_h) ++ produce_rotations(flip_v))
      |> Enum.map(fn tile -> to_str(tile) end)

    if tblr_only,
      do: combinations |> Enum.map(&to_tblr/1),
      else: Enum.zip(combinations |> Enum.map(&to_tblr/1), combinations)
  end

  # Analyse le fichier d'entrée. Remplace # et . au passage en 1 et 0
  def parse(input) do
    input
    |> String.replace("#", "1")
    |> String.replace(".", "0")
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn tile ->
      [head | rest] = String.split(tile, "\n", trim: true)
      [_, number] = String.split(head, " ")
      {String.slice(number, 0..-2) |> String.to_integer(), rest}
    end)
  end
end
