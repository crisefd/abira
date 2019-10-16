defmodule SimulatedAnnealing do
  @moduledoc """
    Basic implementation of the simulated annealing algorithm
    for solving TSP problems. Tested with this set of problems:
   http://elib.zib.de/pub/mp-testdata/tsp/tsplib/tsp/index.html
  """

  @spec run(List.t(), Float.t(), Float.t(), Float.t()) :: Tuple.t()

  @doc """
      Executes the algorithm with the given configuration

    Returns a tuple with first element being the cost of the solution and
    the second being the solution (best permutation found)

    ## Examples

        iex> SimulatedAnnealing.run([{45.8, 76}, {4.0, 60.},..])
        { 6006, [4,5,6..] }
  """
  def run(
        problem_configuration,
        max_iterations \\ 2_000,
        max_temperature \\ 100_000.0,
        cooling_rate \\ 0.98
      ) do
    problem_size = length(problem_configuration)
    points = MapArray.from_list(problem_configuration)
    best = search(points, max_iterations, max_temperature, cooling_rate, problem_size)

    {
      best[:cost],
      best[:array]
    }
  end

  def search(points, max_iterations, max_temperature, cooling_rate, problem_size) do
    initial_permutation = random_permutation(problem_size)
    current = [
      array: initial_permutation,
      cost: cost(initial_permutation, points)
    ]

    find_best(max_iterations, current, points, max_temperature, cooling_rate, current)
  end

  defp find_best(0, _current, _points, _temperature, _cooling_rate, best), do: best

  defp find_best(iterations, current, points, temperature, cooling_rate, best) do
    candidate = neighbor(current, points)
    temperature = temperature * cooling_rate
    current = if should_accept?(candidate, current, temperature), do: candidate, else: current
    best = if candidate[:cost] < best[:cost], do: candidate, else: best
    find_best(iterations - 1, current, points, temperature, cooling_rate, best)
  end

  defp euc_2d(point1, point2) do
    # IO.puts "point1 = #{inspect point1} point2 = #{inspect point2}"
    :math.sqrt(
      ((elem(point1, 0) - elem(point2, 0)) |> :math.pow(2)) +
        ((elem(point1, 1) - elem(point2, 1)) |> :math.pow(2))
    )
    |> round()
  end

  defp cost(permutation, points) do
    permutation_size = MapArray.size(permutation)
    IO.puts "permutation_size = #{permutation_size}"
    cost(permutation, points, 0, permutation_size, 0)
  end

  defp cost(permutation, points, index, permutation_size, distance)
       when index == permutation_size - 1 do
    p1 = permutation[index]
    p2 = permutation[0]
    x = points[p1]
    y = points[p2]
    # IO.puts "index = #{index} permutation_size = #{permutation_size}"
    distance +
      euc_2d(
        x,
        y
      )
  end

  defp cost(permutation, points, index, permutation_size, distance)
       when index < permutation_size - 1 do
     p1 = permutation[index]
     p2 = permutation[index + 1]
     x = points[p1]
     y = points[p2]
     # IO.puts "index = #{index}  permutation_size = #{permutation_size}"
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

  defp random_permutation(size) do
    0..size
    |> Enum.map(fn _ -> round(:sfmt.uniform() * (size - 1)) end)
    |> MapArray.from_list()
  end

  defp stochastic_two_opt(permutation) do
    size = MapArray.size(permutation)
    p1 = round(:sfmt.uniform() * (size - 1))
    x = if p1 == 0, do: size - 1, else: p1 - 1
    y = if p1 == size - 1, do: 0, else: p1 + 1
    to_exclude = [p1, x, y]

    p2 =
      return_valid_p(
        to_exclude,
        round(:sfmt.uniform() * (size - 1)),
        size
      )

    cond do
      p2 < p1 -> change_permutation(p2, p1, permutation)
      true -> permutation
    end
  end

  defp should_accept?(candidate, current, temperature) do
    cond do
      candidate[:cost] <= current[:cost] -> true
      true -> :math.exp((current[:cost] - candidate[:cost]) / temperature) > :sfmt.uniform()
    end
  end

  defp change_permutation(p1, p2, ari) do
    first  = ari |> MapArray.slice(0, p1)
    second = ari |> MapArray.slice(p1 + 1, p2) |> MapArray.reverse()
    third =  ari |> MapArray.slice(p2 + 1, MapArray.size(ari) - 1)

    first |> Map.merge(second) |> Map.merge(third)
  end

  defp return_valid_p(to_exclude, value, limit) do
    cond do
      Enum.member?(to_exclude, value) ->
        return_valid_p(to_exclude, round(:sfmt.uniform() * (limit - 1)), limit)

      true ->
        value
    end
  end

  defp neighbor([array: array, cost: _cost], points) do
    new_array = stochastic_two_opt(array)
    new_cost = cost(new_array, points)
    [array: new_array, cost: new_cost]
  end
end
