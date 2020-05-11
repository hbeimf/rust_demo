defmodule MainAppTest do
  use ExUnit.Case
  doctest MainApp

  test "greets the world" do
    assert MainApp.hello() == :world
  end
end
