defmodule NifOptFlags do
  @moduledoc false
  def multiply_and_add(a, b, c) when is_list(a) and is_list(b) and is_list(c) do
    with {8, 8, 8} <- {Enum.count(a), Enum.count(b), Enum.count(c)} do
      NifOptFlags.Nif.multiply_and_add(a, b, c)
    else
      _ ->
        raise "Invalid input"
    end
  end

  def test do
    multiply_and_add(
      [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
      [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0],
      [0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0]
    )
  end
end
