defmodule RationalTest do
  use ExUnit.Case
  doctest Rational

  test "greets the world" do
    assert Rational.hello() == :world
  end
end
