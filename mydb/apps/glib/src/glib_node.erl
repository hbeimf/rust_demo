% glib_node.erl

-module(glib_node).
-compile(export_all).

-include_lib("glib/include/log.hrl").

% https://www.cnblogs.com/me-sa/archive/2012/12/27/net_kernel.html



get_all_nodes() -> 
	{ok, NodeConfig} = sys_config:get_config(nodes),
	lists:foldl(fun({_, N}, Reply) -> 
		[N|Reply]
	end, [], NodeConfig).


get_nodes() -> 
	% Nodes = [
	% 	'ego1@127.0.0.1'
	% 	, 'ego2@127.0.0.1'
	% 	, 'ego3@127.0.0.1'
	% ],

	{ok, NodeConfig} = sys_config:get_config(nodes),
	Nodes = lists:foldl(fun({_, N}, Reply) -> 
		[N|Reply]
	end, [], NodeConfig),	
	Self = [node()],
	Nodes -- Self.

connect() -> 
	Nodes = get_nodes(),
	?LOG(Nodes),
	% lists:foreach(fun(Node) -> 

	% 	connect(Node)
	% end, Nodes),

	connect(Nodes),
	ok.



connect([]) ->
	ok; 
connect([Node|Tail]) -> 
	% Reply = net_adm:ping(Node),
	% ?LOG({reply, Reply}),
	% ok.
	R = net_kernel:connect_node(Node),
	?LOG(R),
	connect(Tail).











