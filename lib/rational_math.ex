defprotocol RationalMath do
  @moduledoc """
  This protocol is responsible for extending math operators to work with rational numbers.
  """

  def a + b
  def a - b
  def a * b
  def a / b
  def a ** b
end

defimpl RationalMath, for: [Rational, Integer, Float] do
  def a + b, do: Rational.op(a, b, :+)
  def a - b, do: Rational.op(a, b, :-)
  def a * b, do: Rational.op(a, b, :*)
  def a / b, do: Rational.op(a, b, :/)
  def a ** b, do: Rational.op(a, b, :**)
end
