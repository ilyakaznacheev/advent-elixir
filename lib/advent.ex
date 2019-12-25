defmodule Advent do
  @moduledoc """
  Elixir solution of [Advent of Code 2019](https://adventofcode.com/)
  """

  def read_int_file(filename) do
    File.read!(filename)
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def day1(list) do
    list
    |> Enum.map(&Advent.run_d1_fuel/1)
    |> Enum.map(&Advent.run_d1_inc/1)
  end

  @doc """
  Day 1 part 1
  """
  def run_d1_fuel(mass) do
    (mass / 3) - 2
    |> Float.floor(0)
  end

  @doc """
  Day 1 part 2
  """
  def run_d1_inc(mass) do
    if mass <= 0 do
      0
    else
      mass + (run_d1_fuel(mass) |> run_d1_inc)
    end
  end

  @doc """
  Day 2 part 1
  """
  def day2(list) do day2(list, 0) end
  defp day2(list, i) do
    [operation, a, b, c] = Enum.slice(list, i, 4)
    case operation do
      1 ->
        sum = Enum.at(list, a) + Enum.at(list, b)
        List.replace_at(list, c, sum) |> day2(i+4)
      2 ->
        mux = Enum.at(list, a) * Enum.at(list, b)
        List.replace_at(list, c, mux) |> day2(i+4)
      99 ->
        list
    end
  end

  @doc """
  Day 2 part 2
  """
  def day2_bf(list) do
    Enum.reduce 1..100, [], fn(x, acc) ->
      Enum.reduce 1..100, acc, fn(y, acc) ->
        r = list
        |> List.replace_at(1, x)
        |> List.replace_at(2, y)
        |> day2(0)
        |> Enum.at(0)
        case r do
          19690720 -> acc ++ [int_to_str_pad2(x) <> int_to_str_pad2(y)]
          _ -> acc
        end
      end
    end
  end

  defp int_to_str_pad2(n) do
    n
    |> Integer.to_string
    |> String.pad_leading(2, "0")
  end
end


# c("advent.ex")
