# Needlework

Needlework brings additional operators to Elixir that allows you to "thread" results of your functions into other function calls. Basically extending the `Kernel.|>/2` operator.

Just `use Needlework` in your modules and thread away!

Example:
```elixir
defmodule MyModule do
use Needlework

  @spec foo(func :: fun()) :: list()
  def foo(func) do
    func
    ~> Enum.map([1, 2, 3])
  end
end
```

Check the full [documentation](https://hexdocs.pm/needlework)

Inspired by an awesome [dash](https://github.com/magnars/dash.el)

## Installation

The [package](https://hex.pm/packages/needlework) can be installed by adding `needlework` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:needlework, "~> 0.0.1"}
  ]
end
```
