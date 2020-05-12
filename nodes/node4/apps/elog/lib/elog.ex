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

  defmacro print(conn) do 
    quote do 
      :io.format("~n==========================~n~p~n", [%{ :file => __ENV__.file, :line => __ENV__.line, :log => unquote(conn) }])
    end
  end

  defmacro log(log_file, log_conntent) do 
    quote do 
      :sys_log.write_line(__ENV__.file,  __ENV__.line, unquote(log_file), unquote(log_conntent))
    end
  end
  
  defmacro log_json(log_file, log_json) do 
    quote do 
      :sys_log.write_json(__ENV__.file,  __ENV__.line,  unquote(log_file), unquote(log_json))
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
