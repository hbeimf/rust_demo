defmodule GwcTest do
  use ExUnit.Case
  doctest Gwc

  test "greets the world" do
    assert Gwc.hello() == :world
  end
end
