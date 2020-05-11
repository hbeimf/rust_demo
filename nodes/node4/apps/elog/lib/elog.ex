defmodule Elog do
  @moduledoc """
  Documentation for Elog.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elog.hello
      :world

  """
  def hello do
    :world
  end

  defmacro log(log_file, log_conntent) do 
    quote do 
      :sys_log.write_line(__ENV__.file,  __ENV__.line, unquote(log_file), unquote(log_conntent))
    end
    
  end

  # https://elixir-lang.net/gettingStarted/macros.html
  # defmacro my_macro(a, b, c) do
  #   quote do
  #     # Keep what you need to do here to a minimum
  #     # and move everything else to a function
  #     MyModule.do_this_that_and_that(unquote(a), unquote(b), unquote(c))
  #   end
  # end

end
