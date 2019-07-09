%%%-------------------------------------------------------------------
%% @doc go public API
%% @end
%%%-------------------------------------------------------------------

-module(go).
-compile(export_all).

%%====================================================================
%% Cast Api functions
%% 异步消息发送
%%====================================================================

go() ->
    Cast = {list, self()},
    cast(Cast),
    loop().



loop() ->
    receive
        done ->
            ok;
        Msg ->
            io:format("msg:~p~n~n", [Msg]),
            loop()
    end.



%%====================================================================
%% Call Api functions
%% 同步消息发送
%%====================================================================

% 返回时间截
time() ->
    Call = {time, time},
    call(Call).

strtotime() ->
    Str = "2018-01-02",
    strtotime(Str).
strtotime(Str) ->
    Call = {time, strtotime, go_lib:to_str(Str)},
    call(Call).

info() ->
    Call = info,
    call(Call).

parse_list(List) ->
    parse_list(List, 0.1).

parse_list(List, Add) ->
    Call = {list, List, Add},
    call(Call).
% ===================================================================

contains() ->
    Str = "hello world",
    contains(Str, "wo").
contains(Str, SubStr)->
    Call = {str, contains, go_lib:to_str(Str), go_lib:to_str(SubStr)},
    {ok, Bool} = call(Call),
    Bool.

has_prefix() ->
    Str = "hello world!",
    has_prefix(Str, "he").
has_prefix(Str, Prefix) ->
    Call = {str, has_prefix, go_lib:to_str(Str), go_lib:to_str(Prefix)},
    {ok, Bool} = call(Call),
    Bool.

trim() ->
    Str = "\r\n\t\t\t\t\t\r\n\t\t\t2017-06-13\t\t\t\r\n\t\t\t\t\t\t",
    trim(Str).
trim(Str) ->
    Call = {str, trimspace, go_lib:to_str(Str)},
    {ok, NewString} = call(Call),
    NewString.

trim(Str, FindStr) ->
    Call = {str, trim, go_lib:to_str(Str), go_lib:to_str(FindStr)},
    {ok, NewString} = call(Call),
    NewString.

ltrim(Str, FindStr) ->
    Call = {str, trimleft, go_lib:to_str(Str), go_lib:to_str(FindStr)},
    {ok, NewString} = call(Call),
    NewString.

rtrim(Str, FindStr) ->
    Call = {str, trimright, go_lib:to_str(Str), go_lib:to_str(FindStr)},
    {ok, NewString} = call(Call),
    NewString.

str_replace() ->
    str_replace("hello world!!", "e", "XX").
str_replace(StrRes, FindStr, ReplaceTo) ->
    Call = {str, str_replace, go_lib:to_str(StrRes), FindStr, ReplaceTo},
    {ok, NewString} = call(Call),
    NewString.


% From = 'gb2312',
% To = 'utf-8',
iconv(Str, From, To) ->
    case string:len(Str) > 3000 of
        true ->
            long_string_iconv(Str, From, To);
        _ ->
            short_string_iconv(Str, From, To)
    end.

short_string_iconv(Str, From, To) ->
    Call = {iconv, go_lib:to_binary(Str), From, To},
    {ok, ReplyStr} = call(Call),
    ReplyStr.

long_string_iconv(String, From, To) ->
    L = cut_str(go_lib:to_str(String), 3000),
    List = lists:foldl(fun(Str, Reply) ->
      R = short_string_iconv(Str, From, To),
      [R|Reply]
    end, [], L),
    go_lib:implode(List, "").

cut_str(Str, Len) ->
    cut_str([], Str, Len).

cut_str(ReplyList, Str, Len) ->
    StrLen = string:len(Str),
    case StrLen < Len of
        true ->
            [Str|ReplyList];
        _ ->
            Head = string:substr(Str, 1, Len),
            Tail = string:substr(Str, Len+1, StrLen - Len),
            cut_str([Head|ReplyList], Tail, Len)
    end.


parse_html() ->
    Html = "html",
    parse_html(Html).
parse_html(Html) ->
    Call = {str, parse_html, Html},
    call(Call).

%% ==============================================================
call(Call) ->
    GoMBox = go_name_server:get_gombox(),
    gen_server:call(GoMBox, Call).

cast(Cast) ->
    GoMBox = go_name_server:get_gombox(),
    gen_server:cast(GoMBox, {Cast, self()}).
