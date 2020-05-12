defmodule Gwc.GwcInit do
    require Elog

    @moduledoc """
    Documentation for Gwc.
    """
  
    @doc """
    Hello world.
  
    ## Examples
  
        iex> Gwc.hello
        :world
  
    """
    def hello do
      :world
    end

    def init do 
        Elog.log('GwcInit', {:log_test, 1, 2})
        :init
    end

  end
  