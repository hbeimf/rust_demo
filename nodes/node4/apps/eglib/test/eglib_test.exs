defmodule EglibTest do
  use ExUnit.Case
  doctest Eglib

  test "greets the world" do
    assert Eglib.hello() == :world
  end
end
