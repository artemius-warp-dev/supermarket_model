defmodule BasketManagerTest do
  use ExUnit.Case
  doctest BasketManager

  test "greets the world" do
    assert BasketManager.hello() == :world
  end
end
