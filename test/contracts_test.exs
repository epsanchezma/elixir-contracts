defmodule ContractsTest do
  use ExUnit.Case

  defmodule Tank do
    defstruct level: 0, max_level: 10, in_valve: :closed, out_valve: :closed

    use Contracts

    @requires not full?(tank) && tank.in_valve == :open && tank.out_valve == :closed
    @ensures full?(result) && result.in_valve == :closed && result.out_valve == :closed
    def fill(tank) do

    end

    @requires tank.in_valve == :closed && tank.out_valve == :open
    @ensures empty?(result) && result.in_valve == :closed && result.out_valve == :closed
    def empty(tank) do

    end

    def full?(tank) do

    end

    def empty?(tank) do

    end
  end

  test "the truth" do
    assert 1 + 1 == 2
  end
end