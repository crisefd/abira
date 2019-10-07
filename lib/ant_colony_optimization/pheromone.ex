defmodule Pheromone do

	@spec create(Integer.t(), Integer.t()) :: Map.t()

	def create(rows, cols, value \\ nil) do
		row_range = 0..(rows - 1)
		col_range = 0..(cols - 1)
		
		row_range
		|> Enum.map(fn i -> {i, create_row(col_range, value)} end)
		|> Enum.into(%{})
	end

	defp create_row(col_range, value) do
		col_range
		|> Enum.map(fn i -> {i,  value} end)
		|> Enum.into(%{})
	end
end