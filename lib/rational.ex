defmodule Rational do
  @moduledoc """
  Elixir library implementing rational numbers and math.

  The library adds new type of `t:rational/0` numbers and basic math operations for them. Rationals can also interact with integers and floats. Actually this library expands existing functions, so they can work with rationals too. Number operations available:

  * addition
  * subtraction
  * multiplication
  * division
  * power

  ## Some examples

      iex> use Rational
      Kernel

      iex> ~n(2/12)
      2.0/12.0

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
      import Rational
      import RationalMath
      import Kernel, except: [+: 2, -: 2, *: 2, /: 2, **: 2]
    end
  end

  @type rational() :: %Rational{num: number(), denom: number()}
  @type operator() :: :+ | :- | :* | :/ | :**
  defstruct [:num, :denom]

  @doc """
  Returns `true` if `term` is a rational, otherwise returns `false`.

  Allowed in guard tests.
  """
  defguard is_rational(term) when is_struct(term, Rational)

  @doc """
  Parses a string into a rational.

  If successful, returns either a `t:rational/0` or `t:number/0`; otherwise returns `:error`.
  """
  @spec parse(String.t()) :: rational() | number() | :error
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

            result({num, denom})
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
      1.0/4.0

      iex> ~n(-3.1/5)
      -3.1/5.0

  """
  @spec sigil_n(String.t(), list()) :: rational()
  def sigil_n(string, _modifiers), do: parse(string)

  defp gcd(a, 0), do: abs(a)
  defp gcd(a, b), do: gcd(b, rem(a, b))

  @spec op(number(), number(), operator()) :: number()
  def op(a, b, op) when is_number(a) and is_number(b) do
    {res, _} =
      [a, op, b]
      |> Enum.join()
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
