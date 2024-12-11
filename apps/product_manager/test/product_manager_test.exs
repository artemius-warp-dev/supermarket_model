defmodule ProductManagerTest do
  use ExUnit.Case
  doctest ProductManager

  test "greets the world" do
    assert ProductManager.hello() == :world
  end
end
