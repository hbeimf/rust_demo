% glib_node.erl

-module(glib_node).
-compile(export_all).

-include_lib("glib/include/log.hrl").

% https://www.cnblogs.com/me-sa/archive/2012/12/27/net_kernel.html





get_nodes() -> 
	Nodes = [
		'ego1@127.0.0.1'
		, 'ego2@127.0.0.1'
		, 'ego3@127.0.0.1'
	],
	Self = [node()],
	Nodes -- Self.

connect() -> 
	Nodes = get_nodes(),
	?LOG(Nodes),
	lists:foreach(fun(Node) -> 

		connect(Node)
	end, Nodes),
	ok.


connect(Node) -> 
	% Reply = net_adm:ping(Node),
	% ?LOG({reply, Reply}),
	% ok.
	
	R = net_kernel:connect_node(Node),
	?LOG(R),
	ok.











