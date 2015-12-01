defmodule Contracts do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :requires, accumulate: true)
      Module.register_attribute(__MODULE__, :ensures, accumulate: true)

      @contracts %{}

      import Kernel, except: [def: 2]
      import Contracts, only: [def: 2]
    end
  end

  defmacro def(definition, do: content) do
    function_name = case definition do
      {:when, _, [{name, _, _params} | _guards] } -> name
      {name, _, _} -> name
    end

    contracts = Module.get_attribute(__CALLER__.module, :contracts)
    precondition = contracts[function_name][:requires]

    quote do
      Contracts.__on_definition__(__ENV__, unquote(function_name))
      #contracts = Module.get_attribute(__ENV__.module, :contracts)
      #precondition = contracts[unquote(function_name)][:requires]
      Kernel.def(unquote(definition)) do
        unless unquote(precondition), do: raise "Contract not met: blame the client"
        var!(result) = unquote(content)
        var!(result)
      end
    end
  end

  def __on_definition__(env, function) do
    mod = env.module

    requires = Module.get_attribute(mod, :requires) |> List.first |> Code.string_to_quoted!
    ensures = Module.get_attribute(mod, :ensures) |> List.first |> Code.string_to_quoted!
    contract = %{requires: requires, ensures: ensures}

    contracts = Module.get_attribute(mod, :contracts)

    unless Map.has_key?(contracts, function) do
      Module.put_attribute(mod, :contracts, Map.put(contracts, function, contract))
    end

    Module.delete_attribute(mod, :requires)
    Module.delete_attribute(mod, :ensures)
  end
end
