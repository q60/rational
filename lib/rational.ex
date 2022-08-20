defmodule Rational do
  @moduledoc """
  Elixir library implementing rational numbers and math.

  The library adds new type of `t:rational/0` numbers and basic math operations for them. Rationals can also interact with integers and floats. Actually this library expands existing functions, so they can work with rationals too. Number operations available:

  * addition
  * subtraction
  * multiplication
  * division
  * power
  * absolute value

  ## Some examples

      iex> use Rational
      Rational

      iex> ~n(2/12)
      1/6

      iex> ~n(1/4) * ~n(2/3)
      1/6

      iex> ~n(1/6) + ~n(4/7)
      31/42

      iex> ~n(7/9) ** 2
      49/81

      iex> ~n(33/7) - 5
      -2/7

  """

  defmacro __using__(_opts) do
    quote do
      import Kernel, except: [+: 2, -: 2, *: 2, /: 2, **: 2, abs: 1]
      import RationalMath
      import Rational, only: [is_rational: 1, sigil_n: 2, parse: 1, compare: 2]
    end
  end

  defstruct [:num, :denom]

  @type rational() :: %Rational{num: number(), denom: number()}
  @typedoc false
  @type operator() :: :+ | :- | :* | :/ | :**

  @doc """
  Returns `true` if `term` is a rational, otherwise returns `false`.

  Allowed in guard tests.
  """
  defguard is_rational(term) when is_struct(term, Rational)

  @doc """
  Parses a string into a rational.

  If successful, returns either a `t:rational/0` or `t:number/0`; otherwise returns `:error`, raises `ArithmeticError` if denominator is zero.

  ## Examples

      iex> Rational.parse "22/4"
      11/2

      iex> Rational.parse "13/-16"
      13/-16

      iex> Rational.parse "42"
      :error

  """
  @spec parse(String.t()) :: rational() | number() | :error | no_return()
  def parse(string) do
    if String.trim(string) =~ ~r/\s/ do
      :error
    else
      case String.split(string, "/") do
        [a, b] ->
          parsed = Enum.map([a, b], &Float.parse/1)

          if :error in parsed do
            :error
          else
            [{num, _}, {denom, _}] = parsed

            if denom == 0 do
              raise ArithmeticError
            else
              result({num, denom})
            end
          end

        _ ->
          :error
      end
    end
  end

  @doc """
  Handles the sigil `~n` for rationals.

  It returns a `t:rational/0` or `t:number/0`.

  ## Examples

      iex> ~n(1/4)
      1/4

      iex> ~n(-3.1/5)
      -3.1/5.0

  """
  @spec sigil_n(String.t(), list()) :: rational()
  def sigil_n(string, _modifiers), do: parse(string)

  @doc """
  Compares two rationals.

  Returns `:gt` if first rational is greater than the second and `:lt` for vice versa. If the two rationals are equal `:eq` is returned.

  ## Examples

      iex> Rational.compare ~n(1/3), ~n(12/13)
      :lt

      iex> Rational.compare ~n(13/14), ~n(12/13)
      :gt

  """
  @spec compare(rational(), rational()) :: :lt | :eq | :gt
  def compare(a, b) do
    case {a.num / a.denom, b.num / b.denom} do
      {first, second} when first > second ->
        :gt

      {first, second} when first < second ->
        :lt

      _ ->
        :eq
    end
  end

  @doc false
  @spec op(number(), number(), operator()) :: number()
  def op(a, b, op) when is_number(a) and is_number(b) do
    {res, _} =
      [inspect(a), op, inspect(b)]
      |> Enum.join(" ")
      |> Code.eval_string()

    res
  end

  @spec op(number(), rational(), operator()) :: rational() | number()
  def op(a, b, op) when is_number(a) and is_rational(b) do
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

  @spec op(rational(), number(), operator()) :: rational() | number()
  def op(a, b, op) when is_rational(a) and is_number(b) do
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

  @spec op(rational(), rational(), operator()) :: rational() | number()
  def op(a, b, op) when is_rational(a) and is_rational(b) do
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

  @doc false
  @spec op(rational(), :abs) :: rational()
  def op(a, :abs) when is_rational(a), do: %Rational{num: abs(a.num), denom: abs(a.denom)}
  @spec op(number(), :abs) :: number()
  def op(a, :abs) when is_number(a), do: abs(a)

  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  defp result({num, denom}) when num < 0 and denom < 0, do: result({abs(num), abs(denom)})

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
