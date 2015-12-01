defmodule Contracts do
  @default %{pre: true, post: true}
  defmacro __using__(_opts) do
    {:ok, _} = Agent.start_link(fn -> @default end, name: __name__(__CALLER__))
    quote do
      import Kernel, except: [def: 2]
      import Contracts
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    :ok = Agent.stop(__name__(env))
  end

  def __name__(env), do: Module.concat(__MODULE__, env.module)

  defmacro requires(pre) do
    Agent.update(__name__(__CALLER__), &%{&1 | pre: pre})
  end

  defmacro ensures(post) do
    Agent.update(__name__(__CALLER__), &%{&1 | post: post})
  end

  defmacro def(definition, do: content) do
    %{pre: pre, post: post} = Agent.get(__name__(__CALLER__), &(&1))

    ast = quote do
      Kernel.def(unquote(definition)) do
        unless unquote(pre), do: raise "Precondition not met: blame the client"
        var!(result) = unquote(content)
        unless unquote(post), do: raise "Postcondition not met: blame yourself"

        var!(result)
      end
    end
    Agent.update(__name__(__CALLER__), fn _ -> @default end)

    ast
  end
end
