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
