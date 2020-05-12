defmodule Eglib do
  @moduledoc """
  Documentation for Eglib.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Eglib.hello
      :world

  """
  def hello do
    :world
  end

  @cmd_REGISTER 10000
  @cmd_CALL_FUN 10001
  @cmd_CALL_FUN_REPLY 10002
  @cmd_PING 10003
  @cmd_PING_REPLY 10004

  defmacro cmd_REGISTER, do: @cmd_REGISTER
  defmacro cmd_CALL_FUN, do: @cmd_CALL_FUN
  defmacro cmd_CALL_FUN_REPLY, do: @cmd_CALL_FUN_REPLY
  defmacro cmd_PING, do: @cmd_PING
  defmacro cmd_PING_REPLY, do: @cmd_PING_REPLY

  
  # Eglib.cmd_REGISTER
  # def cmd_REGISTER, do: 10000
 

end
