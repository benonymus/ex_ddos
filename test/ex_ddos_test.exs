defmodule ExDdosTest do
  use ExUnit.Case
  doctest ExDdos

  test "greets the world" do
    assert ExDdos.hello() == :world
  end
end
