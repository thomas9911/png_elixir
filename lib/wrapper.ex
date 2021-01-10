defmodule Wrapper do
  @moduledoc """
  from https://stackoverflow.com/questions/54470436/how-to-make-a-wrapper-module-that-includes-functions-from-other-modules
  """
  defmacro __using__(modules) do
    user_defs =
      modules
      |> Enum.map(&Macro.expand(&1, __ENV__))
      |> Enum.map(&{&1, &1.module_info(:exports)})

    for {module, exports} <- user_defs do
      for {func, arity} <- exports, func not in ~w|module_info __info__|a do
        args = for i <- 0..arity, i > 0, do: Macro.var(:"arg#{i}", __MODULE__)

        quote do
          # Use as: unquote("#{func}_#{module}") to resolve dups
          defdelegate unquote(func)(unquote_splicing(args)),
            to: unquote(module),
            as: unquote(func)
        end
      end
    end
  end
end
