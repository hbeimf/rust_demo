% glib_big_pack.erl

-module(glib_big_pack).
-compile(export_all).

% -export([package/2, unpackage/1, test/0]).

-define( UINT, 32/unsigned-big-integer).
% -define( INT, 32/signed-little-integer).
-define( USHORT, 16/unsigned-big-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).
-include_lib("glib/include/log.hrl").


test() ->
	Data = <<"hello world!">>,
	Pack = package(Data),
	?LOG({package, Pack}),
	R = unpackage(Pack),
	?LOG(R),
	ok.


unpackage(PackageBin) when erlang:byte_size(PackageBin) >= 4 ->
	% io:format("parse package =========~n~n"),
	case parse_head(PackageBin) of
		{ok, PackageLen} ->	
			parse_body(PackageLen, PackageBin);
		Any -> 
			Any
	end;
unpackage(_) ->
	{ok, waitmore}. 

parse_head(<<PackageLen:?UINT ,_/binary>> ) ->
	% io:format("parse head ======: ~p ~n~n", [PackageLen]), 
	{ok, PackageLen};
parse_head(_) ->
	error.

parse_body(PackageLen, _ ) when PackageLen > 307200 ->
	error; 
parse_body(PackageLen, PackageBin) ->
	% io:format("parse body -----------~n~n"),
	case PackageBin of 
		<<RightPackage:PackageLen/binary,NextPageckage/binary>> ->
			<<_Len:?UINT,  DataBin/binary>> = RightPackage,
			{ok, DataBin, NextPageckage};
		_ -> {ok, waitmore}
	end.

package(DataBin) ->
	Len = byte_size(DataBin)+4,
	<<Len:?UINT, DataBin/binary>>.
