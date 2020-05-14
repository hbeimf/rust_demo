% nif_fun.erl
-module(fc).
-export([load/0
	% , add/2
	, hello/0]).

-export([
	create_fish_control/2
	, save_to_file/1
	, save_and_release/1
	, catch_fish/4
	, set_difficulty/3
	, set_place_type/2
	, chou_fang/2
	, get_inner_data/1
]).
 
load() ->
        erlang:load_nif("./fc", 0).
 
hello() ->
      "NIF library not loaded".

% add(_A, _B) ->
%         io:format("this function is not defined!~n").

% =====================================
% bool
create_fish_control(_FilePath_Char, _TableId_Int) ->
	"NIF library not loaded".

% void
save_to_file(_TableId_Int) -> 
	"NIF library not loaded".

% void
save_and_release(_TableId_Int) -> 
	"NIF library not loaded".

% bool
catch_fish(_TableId_Int, _Who_Int, _BulletCoin_Int, _FishCoin_Int) ->
	 "NIF library not loaded".

% bool
set_difficulty(_TableId_Int, _Level_Int, _Fif_Int) -> 
	"NIF library not loaded".

% bool
set_place_type(_TableId_Int, _Pt_Int) -> 
	"NIF library not loaded".

% bool
chou_fang(_TableId_Int, _CoinNum_Int) -> 
	"NIF library not loaded".

% char
get_inner_data(_TableId_Int) -> 
	"NIF library not loaded".

%  maomao@maomao-VirtualBox:/erlang/rust_demo/nif$ erl
% Erlang/OTP 18 [erts-7.3] [source] [64-bit] [smp:2:2] [async-threads:10] [hipe] [kernel-poll:false]

% Eshell V7.3  (abort with ^G)
% 1> c(nif_fun).
% {ok,nif_fun}
% 2> nif_fun:load().
% ok
% 3> nif_fun:hello().
% "Hello world!"
% 4> nif_fun:add(2,5).
