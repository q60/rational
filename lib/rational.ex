defimpl String.Chars, for: Rational do
  def to_string(ratio) do
    "#{ratio.num}/#{ratio.denom}"
  end
end

defimpl Inspect, for: Rational do
  def inspect(ratio, _opts) do
    "#{ratio.num}/#{ratio.denom}"
  end
end

defmodule Rational do
  defmacro __using__(_opts) do
    quote do
      import Rational
      import RationalMath
      import Kernel, except: [+: 2, -: 2, *: 2, /: 2, **: 2]
    end
  end

  defstruct [:num, :denom]

  defmacro is_rational(term) do
    quote do
      is_struct(unquote(term)) and
        :erlang.is_map_key(:num, unquote(term)) and
        :erlang.is_map_key(:denom, unquote(term))
    end
  end

  def sigil_n(string, _) do
    [a, b] =
      String.split(string, "/")
      |> Enum.map(fn x ->
        {i, _} = Float.parse(x)
        i
      end)

    %Rational{num: a, denom: b}
  end

  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  def rat_op(a, b, op) when is_number(a) and is_number(b) do
    {res, _} =
      [a, op, b]
      |> Enum.join()
      |> Code.eval_string()

    res
  end

  def rat_op(a, b, op) when is_number(a) and is_rational(b) do
    case op do
      :+ ->
        {a * b.denom + b.num, b.denom}

      :- ->
        {a * b.denom - b.num, b.denom}

      :* ->
        {a * b.num, b.denom}

      :/ ->
        {a * b.denom, b.num}

      :** ->
        {a ** (b.num / b.denom), 1}
    end
    |> result()
  end

  def rat_op(a, b, op) when is_rational(a) and is_number(b) do
    case op do
      :+ ->
        {b * a.denom + a.num, a.denom}

      :- ->
        {a.num - b * a.denom, a.denom}

      :* ->
        {b * a.num, a.denom}

      :/ ->
        {a.num, a.denom * b}

      :** ->
        {a.num ** b, a.denom ** b}
    end
    |> result()
  end

  def rat_op(a, b, op) when is_rational(a) and is_rational(b) do
    case op do
      :+ ->
        {a.num * b.denom + b.num * a.denom, a.denom * b.denom}

      :- ->
        {a.num * b.denom - b.num * a.denom, a.denom * b.denom}

      :* ->
        {a.num * b.num, a.denom * b.denom}

      :/ ->
        {a.num * b.denom, a.denom * b.num}

      :** ->
        {a.num ** (b.num / b.denom), a.denom ** (b.num / b.denom)}
    end
    |> result()
  end

  defp result({num, denom}) do
    cond do
      num == denom ->
        1

      denom == 1 ->
        num

      num == 0 ->
        0

      is_float(num) or is_float(denom) ->
        cond do
          trunc(num) == num && trunc(denom) == denom ->
            {num, denom} = {trunc(num), trunc(denom)}
            g = gcd(num, denom)

            %Rational{
              num: div(num, g),
              denom: div(denom, g)
            }

          true ->
            %Rational{
              num: num,
              denom: denom
            }
        end

      true ->
        g = gcd(num, denom)

        %Rational{
          num: div(num, g),
          denom: div(denom, g)
        }
    end
  end
end
