defmodule Needlework do
  @moduledoc """
  Needlework brings additional operators to Elixir that allows you to "thread" results of your functions into other function calls. Basically extending the `Kernel.|>/2` operator.

  Just `use Needlework` in your modules and thread away!

  Example:
  ```
  defmodule MyModule do
  use Needlework

    @spec foo(func :: fun()) :: list()
    def foo(func) do
      func
      ~> Enum.map([1, 2, 3])
    end
  end
  ```
  """
  defmacro __using__(_) do
    quote do
      import Needlework, only: :macros
    end
  end

  @type ok :: {:ok, any()}
  @type error :: {:error, any()}

  @doc """
  Wraps the value in `t:Needlework.ok/0` tuple.

  Example:
      iex> 5 |> Needlework.ok_unit()
      {:ok, 5}
      iex> {:ok, 5} |> Needlework.ok_unit()
      {:ok, 5}
      iex> {:error, ""} |> Needlework.ok_unit()
      {:error, ""}
  """
  @spec ok_unit(any) :: {:ok | :error, any}
  def ok_unit({:ok, _} = value), do: value
  def ok_unit({:error, _} = value), do: value
  def ok_unit(value), do: {:ok, value}

  @doc """
  Bind operator.

  If value on the left is a plain value -> converts it to `t:Needlework.ok/0` | `t:Needlework.error/0` tuple
  then desctructures the tuple. If it was `t:Needlework.ok/0` tuple -> passes the value for evaluation.
  If it was `t:Needlework.ok/0` tuple -> skips the evaluation

  Example:
      iex> import Needlework
      iex> foo = fn x -> {:ok, x * 2} end
      iex> 2 <|> foo.() <|> foo.() <|> foo.()
      {:ok, 16}
      iex> bar = fn _ -> {:error, "impossible"} end
      iex> 2 <|> foo.() <|> bar.() <|> foo.()
      {:error, "impossible"}
  """
  defmacro left <|> right do
    quote do
      unquote(left)
      |> Needlework.ok_unit()
      |> (fn
            {:ok, value} -> value |> unquote(right)
            {:error, reason} -> {:error, reason}
          end).()
    end
  end

  @doc """
  Same as `Needlework.<|>/2` but places the value instead of `_`.

  If no `_` present works like a `Needlework.<|>/2`

  Examples:
      iex> import Needlework
      iex> foo = fn x, y -> {:ok, x ++ y} end
      iex> [1, 2, 3] <~> foo.(_, [1, 2, 3]) <~> foo.([4, 5, 6], _)
      {:ok, [4, 5, 6, 1, 2, 3, 1, 2, 3]}
      iex> [1, 2, 3] <~> foo.([1, 2, 3]) <~> foo.([4, 5, 6])
      {:ok, [1, 2, 3, 1, 2, 3, 4, 5, 6]}
      iex> bar = fn _, _ -> {:error, "reason"} end
      iex> [1, 2, 3] <~> bar.([1, 2, 3]) <~> foo.([4, 5, 6])
      {:error, "reason"}
  """
  defmacro left <~> right do
    quote do
      unquote(left)
      |> Needlework.ok_unit()
      |> (fn
            {:ok, value} -> value ~>> unquote(right)
            {:error, reason} -> {:error, reason}
          end).()
    end
  end

  @doc """
  Allows to thread the value on the left as the last argument

  Example:
      iex> import Needlework
      iex> [1, 2, 3] ~> Kernel.++([4, 5, 6])
      [4, 5, 6, 1, 2, 3]
      iex> fn x -> x*2 end ~> Enum.map([1, 2, 3])
      [2, 4, 6]
  """
  defmacro left ~> right do
    new_right = add_last_arg(right, left)

    quote do
      unquote(new_right)
    end
  end

  @doc """
  Allows to thread the value on the left to a specific spot on the right.

  Value from the left will be placed instead of `_`.
  If no `_` present works like a regular `Kernel.|>/2`

  Example:
      iex> import Needlework
      iex> [1, 2, 3] ~>> Kernel.++([4, 5, 6], _)
      [4, 5, 6, 1, 2, 3]
      iex> [1, 2, 3] ~>> Kernel.++([4, 5, 6])
      iex> [] ~>> Enum.reduce([1, 2, 3], _, fn x, acc -> [x | acc] end)
      [3, 2, 1]
  """
  defmacro left ~>> right do
    case replace_underscore_args(right, left) do
      {:ok, new_args} ->
        new_right = put_elem(right, 2, new_args)

        quote do
          unquote(new_right)
        end

      {:error, _} ->
        quote do
          unquote(left)
          |> unquote(right)
        end
    end
  end

  defp replace_underscore_args({_, _, args}, replacement) do
    Enum.reduce(args, {:error, []}, fn
      {:_, _, _}, {_, args} -> {:ok, args ++ [replacement]}
      val, {res, args} -> {res, args ++ [val]}
    end)
  end

  defp add_last_arg({name, context, args}, argument), do: {name, context, args ++ [argument]}
end
