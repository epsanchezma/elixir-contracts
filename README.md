Contracts
=========

Design by Contract for Elixir


Usage
======

```elixir
requires x > 0
ensures (result * result) <= x && (result+1) * (result+1) > x
def sqrt(x) do
  :math.sqrt(x)
end
```
