-module(glibpack).
-compile(export_all).

% -export([package/2, unpackage/1, test/0]).

-define( UINT, 32/unsigned-little-integer).
% -define( INT, 32/signed-little-integer).
-define( USHORT, 16/unsigned-little-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).

% -define( UINT, 32/unsigned-big-integer).
% -define( USHORT, 16/unsigned-big-integer).
	
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

parse_body(PackageLen, _ ) when PackageLen > 9000 ->
	error; 
parse_body(PackageLen, PackageBin) ->
	% io:format("parse body -----------~n~n"),
	case PackageBin of 
		<<RightPackage:PackageLen/binary,NextPageckage/binary>> ->
			<<_Len:?UINT, CmdId:?USHORT, ServerType:?USHORT, OtherParam:?UINT, DataBin/binary>> = RightPackage,
			% tcp_controller:action(Cmd, DataBin),
			% unpackage(NextPageckage);
			{ok, {CmdId, ServerType, OtherParam, DataBin}, RightPackage, NextPageckage};
		_ -> {ok, waitmore}
	end.


package(CmdId, DataBin) ->
	package(CmdId, 0, 0, DataBin).

package(CmdId, ServerType, DataBin) ->
	package(CmdId, ServerType, 0, DataBin).

package(CmdId, ServerType, OtherParam, DataBin) ->
	Len = byte_size(DataBin)+12,
	<<Len:?UINT, CmdId:?USHORT, ServerType:?USHORT, OtherParam:?UINT, DataBin/binary>>.



%% unpackage_gs解析从游戏服发过来的包
% unpackage_gs(PackageBin) when erlang:byte_size(PackageBin) >= 4 ->
% 	% io:format("parse package =========~n~n"),
% 	case parse_head(PackageBin) of
% 		{ok, PackageLen} ->	
% 			parse_body_gs(PackageLen, PackageBin);
% 		Any -> 
% 			Any
% 	end;
% unpackage_gs(_) ->
% 	{ok, waitmore}. 

% parse_body_gs(PackageLen, _ ) when PackageLen > 9000 ->
% 	error; 
% parse_body_gs(PackageLen, PackageBin) ->
% 	% io:format("parse body -----------~n~n"),
% 	case PackageBin of 
% 		<<RightPackage:PackageLen/binary,NextPageckage/binary>> ->
% 			{ok, RightPackage, NextPageckage};
% 		_ -> {ok, waitmore}
% 	end.
