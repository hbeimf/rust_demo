% mysqlc_comm_SUITE.erl
-module(mysqlc_comm_SUITE).
-compile(export_all).


% -include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

all() ->
	[test1].

test1(_) ->
	io:format("test... ~n"),
            % glib:write_req({?MODULE, ?LINE, test}, "mysqlc_comm_test"),
	ok.



% [{sasl,"SASL  CXC 138 11","2.7"},
%  {mysqlc_demo,"An OTP application","0.1.0"},
%  {mysqlc_comm,"An OTP application","0.1.0"},
%  {glib,"An OTP application","0.2.5"},
%  {esnowflake,"Twitter's Snowflake UUID generator in Erlang",
%              "0.2.0"},
%  {inets,"INETS  CXC 138 49","6.2"},
%  {ssl,"Erlang/OTP SSL application","7.3"},
%  {public_key,"Public key infrastructure","1.1.1"},
%  {asn1,"The Erlang ASN1 compiler version 4.0.2","4.0.2"},
%  {crypto,"CRYPTO","3.6.3"},
%  {stdlib,"ERTS  CXC 138 10","2.8"},
%  {kernel,"ERTS  CXC 138 10","4.2"}]


test() ->
	application:start(esnowflake),
	application:start(inets),

	application:start(ssl),
	application:start(public_key),

	application:start(asn1),
	application:start(crypto),

	application:start(stdlib),
	application:start(kernel),

	application:start(mysqlc_comm),

    PoolConfigList = [
        #{
            pool_id=>1,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb",
            pool_size => 2
        }
        , #{
            pool_id=>2,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb",
            pool_size=> 5
        }
        , #{
            pool_id=>3,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb"
            % pool_size=> 5
        }

    ],
    lists:foreach(fun(PoolConfig) -> 
        mysqlc_comm:start_pool(PoolConfig)
    end, PoolConfigList).



% test_fail(_) ->
% 	% io:format("hello test~n"),
% 	Reply = demo:hello(),
% 	% io:format("reply: ~p~n", [Reply]),
% 	?assert(ok == Reply),
% 	% io:format("test... ~n"),
% 	false.

% test3(_) ->
% 	io:format("test... ~n"),
% 	ok.

% eunit(_) ->
% 	ok = eunit:test({application, erl_test}).