%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Dec 2019 8:01 PM
%%%-------------------------------------------------------------------
-module(tt).

-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").


t_add() ->
  lists:foreach(
    fun(Id) ->
      lists:foreach(
        fun(Index) ->
          ?LOG({Id, Index}),
          table_key_pid:add({Id, Index}, self())
        end, lists:seq(1, 10000))
    end, lists:seq(1, 1000)),
  ok.



