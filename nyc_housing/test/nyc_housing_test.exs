defmodule NycHousingTest do
  use ExUnit.Case
  doctest NycHousing

  test "greets the world" do
    assert NycHousing.hello() == :world
  end
end
