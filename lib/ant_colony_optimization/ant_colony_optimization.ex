defmodule AntColonyOptimization do


  """ 
  def global_update_pheromone(phero, cand, decay)
      cand[:vector].each_with_index do |x, i|
      y = (i==cand[:vector].size-1) ? cand[:vector][0] : cand[:vector][i+1]
      value = ((1.0-decay)*phero[x][y]) + (decay*(1.0/cand[:cost]))
      phero[x][y] = value
      phero[y][x] = value
    end
  end
  """

  defp global_update_pheromone(pheromone, candidate, decay_rate) do
    
  end


  defp initialise_pheromone_matrix(num_points, init_pheromone_val) do
    Pheromone.create(num_points, num_points, init_pheromone_val)
  end

  defp stepwise_const(points, pheromones, heuristic_coefficient, greediness_factor) do
    stepwise_const(points, pheromones, heuristic_coefficient, greediness_factor, [], nil, 0)
  end

   defp stepwise_const(points, pheromones,
                      heuristic_coefficient,
                      greediness_factor, permutation_ls,
                      last_item_perm, perm_count) when map_size(points) == perm_count do
     permutation_ls                   
  end

  defp stepwise_const(points, pheromones,
                      heuristic_coefficient,
                      greediness_factor, permutation_ls,
                      last_item_perm, perm_count) when permutation_ls = [] do
    choices = calculate_choices(points, nil, [],
                               pheromone, heuristic_coefficient,
                               1.0)
    greedy = :sfmt.uniform() <= greediness_factor
    next_point = if greedy, do: greedy_select(choices), else: prob_select(choices)
    stepwise_const(points, pheromones, heuristic_coefficient,
                   greediness_factor, [ next_point | permutation_ls],
                   next_point, perm_count + 1)
  end

  defp stepwise_const(points, pheromones,
                      heuristic_coefficient,
                      greediness_factor, permutation_ls, last_item_perm) do
    choices = calculate_choices(points, last_item_perm, [],
                               pheromone, heuristic_coefficient,
                               1.0)
    greedy = :sfmt.uniform() <= greediness_factor
    next_point = if greedy, do: greedy_select(choices), else: prob_select(choices)
    stepwise_const(points, pheromones, heuristic_coefficient,
                   greediness_factor, [ next_point | permutation_ls], last_item_perm)
  end

  defp greedy_select(choices) do
    choices |> Enum.max_by( fn c ->  c[:probability]  end)
  end

  defp prob_select(choices) do
    sum = choices |> Enum.sum()
    prob_select(choices, sum, length(choices))
  end

  defp prob_select(choices, sum, size) when sum == 0 do
    r = :sfmt.uniform() * (size - 1)
    choice = Enum.at(choices, r) 
    choices[:point]
  end

  defp prob_select(choices, sum, size) do
    v = :sfmt.uniform()
    prob_select_point(choices, sum, v)
  end

  def prob_select_point([choice | []], _sum, _v) do
    choice[:point]
  end

  defp prob_select_point([choice | choices], _sum, v) when v <= 0 do
    choice[:point]
  end

  def prob_select_point([choice | choices], sum, v) do
    prob_select_point(choices, sum, v - choice[:probability] / sum)
  end

  defp calculate_choices(points, last_point, to_exclude,
                         pheromone, heuristic_coefficient,
                         history_coefficient) do
    calculate_choices(points, last_point, to_exclude, pheromone,
                      heuristic_coefficient, history_coefficient, 
                      0, map_size(points))
  end


  defp calculate_choices(points, last_point, to_exclude,
                         pheromone, heuristic_coefficient,
                         history_coefficient, step, size, choices) do
    point = points[step]
    cond do
      step === size -> 
        choices
      Enum.member?(to_exclude, step) -> 
        calculate_choices(points, last_point, to_exclude,
                          pheromone, heuristic_coefficient
                          history_coefficient, step + 1, size ,choices)
        true -> 
          history = :math.pow(pheromone[last_point][step],
                              history_coefficient)
          distance = euc_2d(points[last_city], points)
          heuristic = :math.pow(1.0 / distance,  heuristic_coefficient)
          choice = %{ point: step,
                      history: history,
                      distance: distance
                      heuristic: heuristic
                      probability: history * heuristic }
          calculate_choices(points, last_point, to_exclude,
                            pheromone, heuristic_coefficient
                            history_coefficient, step + 1, size, [choice | choices])
        
    end
  end


  defp euc_2d(point1, point2) do
    :math.sqrt(
      ((elem(point1, 0) - elem(point2, 0)) |> :math.pow(2)) +
        ((elem(point1, 1) - elem(point2, 1)) |> :math.pow(2))
    )
    |> round()
  end

  defp cost(permutation, points) do
    permutation_size = :array.size(permutation)
    cost(permutation, points, 0, permutation_size, 0)
  end

  defp cost(permutation, points, index, permutation_size, distance)
       when index == permutation_size - 1 do
    p1 = :array.get(index, permutation)
    p2 = :array.get(0, permutation)
    x = points[p1]
    y = points[p2]
    distance +
      euc_2d(
        x,
        y
      )
  end

  defp cost(permutation, points, index, permutation_size, distance)
       when index < permutation_size - 1 do
    p1 = :array.get(index, permutation)
    p2 = :array.get(index + 1, permutation)
    x = points[p1]
    y = points[p2]
    cost(
      permutation,
      points,
      index + 1,
      permutation_size,
      distance +
        euc_2d(
          x,
          y
        )
    )
  end
end
