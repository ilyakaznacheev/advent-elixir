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

  def day3(list) do
    list
    |> String.split("\n")
    |> Enum.map(fn x -> day3_parse_path(x) end)
  end

  def day3_parse_path(list) do
    list
    |> String.split(",")
    |> Enum.map(fn x ->
      String.split_at(x, 1)
      |> (fn {d, num} ->
        {String.to_atom(d), elem(Integer.parse(num),0)}
      end).()
    end)
  end

  defp day3_path_to_point_pairs(path_list) do
    Enum.reduce(path_list, %{:x => 0, :y => 0, :path=>0, :res => []}, fn ({d, num}, %{:x=>x, :y=>y, :path=>path, :res=>res}) ->
      [xn,yn] = case d do
        :D -> [x,y - num]
        :U -> [x,y + num]
        :L -> [x - num,y]
        :R -> [x + num,y]
        _ -> :error
      end
      path = path + num
      n = res ++ [[{min(x,xn),min(y,yn)},{max(x,xn),max(y,yn)},path]]
      %{:x=>xn, :y=>yn, :path=>path, :res=>n}
    end)
    |> Map.fetch(:res)
  end

  defp day3_path_intersections(points1, points2) do
    intersects = fn (a, b) ->
      [{ax1, ay1}, {ax2, ay2}, step_a] = a
      [{bx1, by1}, {bx2, by2}, step_b] = b

      orientation = fn  [{x1, y1}, {x2, y2}, _] ->
        cond do
          x1 == x2 -> :vertical
          y1 == y2 -> :horisontal
        end
      end

      orient_a = orientation.(a)
      orient_b = orientation.(b)

      cond do
        orient_a == orient_b ->
          {false, "parallel"}
        orient_a == :vertical && (( by1 < ay1 || by2 > ay2 ) || (ax1 < bx1 || ax2 > bx2 )) ->
          {false, "no intersection A"}
        orient_a == :horisontal && (( bx1 < ax1 || bx1 > ax2 ) || (ay1 < by1 || ay2 > by2 )) ->
          {false, "no intersection B"}
        orient_a == :vertical ->
          {true, {ax1, by1}, (step_a + step_b - (bx2-ax2 + ay2-by2))}
        orient_a == :horisontal ->
          {true, {bx1, ay1}, (step_a+step_b - (ax2-bx2 + by2-ay2))}
      end
    end

    for p1 <- points1, p2 <- points2 do
      intersects.(p1, p2)
    end
  end

  defp day3_all_intersections(points1, points2) do
    day3_path_intersections(points1, points2)
    |> Enum.reduce([], fn (x, acc) ->
      case x do
        {true, point, step}
          -> acc ++ [%{:path => abs(elem(point, 0)) + abs(elem(point, 1)), :point => point, :step => step}]
        _ -> acc
      end
    end)
  end

  @doc """
  find the nearest wire intersection
  """
  def day3(s1, s2) do
    a = day3_parse_path(s1) |> day3_path_to_point_pairs
    b = day3_parse_path(s2) |> day3_path_to_point_pairs
    case [a,b] do
      [{:ok,path1},{:ok,path2}] ->
        day3_all_intersections(path1,path2)
        |> Enum.sort(&(&1[:path] < &2[:path]))
        |> List.first
      _ -> :error
    end
  end

  @doc """
  find a shortest path to an intersection
  """
  def day3_second_part(s1, s2) do
    a = s1 |> day3_parse_path |> day3_path_to_point_pairs
    b = s2 |> day3_parse_path |> day3_path_to_point_pairs
    case [a,b] do
      [{:ok,path1},{:ok,path2}] ->
        day3_all_intersections(path1,path2)
        |> Enum.sort(&(&1[:step] < &2[:step]))
        |> List.first
      _ -> :error
    end
  end
end

# c("lib/advent.ex")
