defprotocol RationalMath do
  def a + b
  def a - b
  def a * b
  def a / b
  def a ** b
end

defimpl RationalMath, for: [Rational, Integer, Float] do
  def a + b, do: Rational.rat_op(a, b, :+)
  def a - b, do: Rational.rat_op(a, b, :-)
  def a * b, do: Rational.rat_op(a, b, :*)
  def a / b, do: Rational.rat_op(a, b, :/)
  def a ** b, do: Rational.rat_op(a, b, :**)
end
