defmodule ContractsTest do
  use ExUnit.Case

  defmodule Tank do
    defstruct level: 0, max_level: 10, in_valve: :closed, out_valve: :closed

    use Contracts

    requires not full?(tank) && tank.in_valve == :open && tank.out_valve == :closed
    ensures full?(result) && result.in_valve == :closed && result.out_valve == :closed
    def fill(tank) do
      %Tank{tank | level: 10, in_valve: :closed}
    end

    requires tank.in_valve == :closed && tank.out_valve == :open
    ensures empty?(result) && result.in_valve == :closed && result.out_valve == :closed
    def empty(tank) do
      %Tank{tank | level: 1, out_valve: :closed}
      # %Tank{tank | level: 0, out_valve: :closed}
    end

    def full?(tank) do
      tank.level == tank.max_level
    end

    def empty?(tank) do
      tank.level == 0
    end
  end

  test "fill/1 fills the tank with water" do
    tank = %Tank{level: 10}
    # tank = %Tank{level: 5, in_valve: :open}
    tank = Tank.fill(tank)
    assert Tank.full?(tank)
  end

  test "empty/1 empties the tank" do
    tank = %Tank{level: 10, out_valve: :open}
    tank = Tank.empty(tank)
    assert Tank.empty?(tank)
  end
end
