-file("/usr/local/erlang_18.3/lib/erlang/lib/parsetools-2.1.1/include/leexinc.hrl", 0).
%% The source of this file is part of leex distribution, as such it
%% has the same Copyright as the other files in the leex
%% distribution. The Copyright is defined in the accompanying file
%% COPYRIGHT. However, the resultant scanner generated by leex is the
%% property of the creator of the scanner and is not covered by that
%% Copyright.

-module(zucchini_lexer).

-export([string/1,string/2,token/2,token/3,tokens/2,tokens/3]).
-export([format_error/1]).

%% User code. This is placed here to allow extra attributes.
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 22).

-compile({inline, to_key/2}).
to_key(TokenChars, TokenLen) ->
    S = string:substr(TokenChars, 1, TokenLen-1),
    K = string:strip(S),
    list_to_atom(K).

-compile({inline, to_atom/1}).
to_atom(TokenChars) ->
    list_to_atom(string:strip(TokenChars, left)).

-compile({inline, to_integer/1}).
to_integer(TokenChars) ->
    list_to_integer(string:strip(TokenChars, left)).

-compile({inline, to_float/1}).
to_float(TokenChars) ->
    list_to_float(string:strip(TokenChars, left)).

-compile({inline, to_string/1}).
to_string(TokenChars) ->
    S = string:strip(TokenChars, left),
    string:substr(S, 2, length(S)-2).

-file("/usr/local/erlang_18.3/lib/erlang/lib/parsetools-2.1.1/include/leexinc.hrl", 14).

format_error({illegal,S}) -> ["illegal characters ",io_lib:write_string(S)];
format_error({user,S}) -> S.

string(String) -> string(String, 1).

string(String, Line) -> string(String, Line, String, []).

%% string(InChars, Line, TokenChars, Tokens) ->
%% {ok,Tokens,Line} | {error,ErrorInfo,Line}.
%% Note the line number going into yystate, L0, is line of token
%% start while line number returned is line of token end. We want line
%% of token start.

string([], L, [], Ts) ->                     % No partial tokens!
    {ok,yyrev(Ts),L};
string(Ics0, L0, Tcs, Ts) ->
    case yystate(yystate(), Ics0, L0, 0, reject, 0) of
        {A,Alen,Ics1,L1} ->                  % Accepting end state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {A,Alen,Ics1,L1,_S1} ->              % Accepting transistion state
            string_cont(Ics1, L1, yyaction(A, Alen, Tcs, L0), Ts);
        {reject,_Alen,Tlen,_Ics1,L1,_S1} ->  % After a non-accepting state
            {error,{L0,?MODULE,{illegal,yypre(Tcs, Tlen+1)}},L1};
        {A,Alen,_Tlen,_Ics1,_L1,_S1} ->
            string_cont(yysuf(Tcs, Alen), L0, yyaction(A, Alen, Tcs, L0), Ts)
    end.

%% string_cont(RestChars, Line, Token, Tokens)
%% Test for and remove the end token wrapper. Push back characters
%% are prepended to RestChars.

-dialyzer({nowarn_function, string_cont/4}).

string_cont(Rest, Line, {token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, {end_token,T}, Ts) ->
    string(Rest, Line, Rest, [T|Ts]);
string_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, [T|Ts]);
string_cont(Rest, Line, skip_token, Ts) ->
    string(Rest, Line, Rest, Ts);
string_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    string(NewRest, Line, NewRest, Ts);
string_cont(_Rest, Line, {error,S}, _Ts) ->
    {error,{Line,?MODULE,{user,S}},Line}.

%% token(Continuation, Chars) ->
%% token(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {token,State,CurrLine,TokenChars,TokenLen,TokenLine,AccAction,AccLen}

token(Cont, Chars) -> token(Cont, Chars, 1).

token([], Chars, Line) ->
    token(yystate(), Chars, Line, Chars, 0, Line, reject, 0);
token({token,State,Line,Tcs,Tlen,Tline,Action,Alen}, Chars, _) ->
    token(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Action, Alen).

%% token(State, InChars, Line, TokenChars, TokenLen, TokenLine,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% The argument order is chosen to be more efficient.

token(S0, Ics0, L0, Tcs, Tlen0, Tline, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{token,S1,L1,Tcs,Alen1,Tline,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            token_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline));
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{token,S1,L1,Tcs,Tlen1,Tline,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     true -> {eof,L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,Ics1,L1,_S1} ->    % No token match
            Error = {Tline,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            {done,{error,Error,L1},Ics1};
        {A1,Alen1,_Tlen1,_Ics1,_L1,_S1} ->       % Use last accept match
            token_cont(yysuf(Tcs, Alen1), L0, yyaction(A1, Alen1, Tcs, Tline))
    end.

%% token_cont(RestChars, Line, Token)
%% If we have a token or error then return done, else if we have a
%% skip_token then continue.

-dialyzer({nowarn_function, token_cont/3}).

token_cont(Rest, Line, {token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, {end_token,T}) ->
    {done,{ok,T,Line},Rest};
token_cont(Rest, Line, {end_token,T,Push}) ->
    NewRest = Push ++ Rest,
    {done,{ok,T,Line},NewRest};
token_cont(Rest, Line, skip_token) ->
    token(yystate(), Rest, Line, Rest, 0, Line, reject, 0);
token_cont(Rest, Line, {skip_token,Push}) ->
    NewRest = Push ++ Rest,
    token(yystate(), NewRest, Line, NewRest, 0, Line, reject, 0);
token_cont(Rest, Line, {error,S}) ->
    {done,{error,{Line,?MODULE,{user,S}},Line},Rest}.

%% tokens(Continuation, Chars, Line) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.
%% Must be careful when re-entering to append the latest characters to the
%% after characters in an accept. The continuation is:
%% {tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Tokens,AccAction,AccLen}
%% {skip_tokens,State,CurrLine,TokenChars,TokenLen,TokenLine,Error,AccAction,AccLen}

tokens(Cont, Chars) -> tokens(Cont, Chars, 1).

tokens([], Chars, Line) ->
    tokens(yystate(), Chars, Line, Chars, 0, Line, [], reject, 0);
tokens({tokens,State,Line,Tcs,Tlen,Tline,Ts,Action,Alen}, Chars, _) ->
    tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Ts, Action, Alen);
tokens({skip_tokens,State,Line,Tcs,Tlen,Tline,Error,Action,Alen}, Chars, _) ->
    skip_tokens(State, Chars, Line, Tcs ++ Chars, Tlen, Tline, Error, Action, Alen).

%% tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Ts, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        %% Accepting end state, we have a token.
        {A1,Alen1,Ics1,L1} ->
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% Accepting transition state, can take more chars.
        {A1,Alen1,[],L1,S1} ->                  % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Alen1,Tline,Ts,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->               % Take what we got
            tokens_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Ts);
        %% After a non-accepting state, maybe reach accept state later.
        {A1,Alen1,Tlen1,[],L1,S1} ->            % Need more chars to check
            {more,{tokens,S1,L1,Tcs,Tlen1,Tline,Ts,A1,Alen1}};
        {reject,_Alen1,Tlen1,eof,L1,_S1} ->     % No token match
            %% Check for partial token which is error, no need to skip here.
            Ret = if Tlen1 > 0 -> {error,{Tline,?MODULE,
                                          %% Skip eof tail in Tcs.
                                          {illegal,yypre(Tcs, Tlen1)}},L1};
                     Ts == [] -> {eof,L1};
                     true -> {ok,yyrev(Ts),L1}
                  end,
            {done,Ret,eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            %% Skip rest of tokens.
            Error = {L1,?MODULE,{illegal,yypre(Tcs, Tlen1+1)}},
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,_Tlen1,_Ics1,_L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            tokens_cont(yysuf(Tcs, Alen1), L0, Token, Ts)
    end.

%% tokens_cont(RestChars, Line, Token, Tokens)
%% If we have an end_token or error then return done, else if we have
%% a token then save it and continue, else if we have a skip_token
%% just continue.

-dialyzer({nowarn_function, tokens_cont/4}).

tokens_cont(Rest, Line, {token,T}, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, [T|Ts], reject, 0);
tokens_cont(Rest, Line, {end_token,T}, Ts) ->
    {done,{ok,yyrev(Ts, [T]),Line},Rest};
tokens_cont(Rest, Line, {end_token,T,Push}, Ts) ->
    NewRest = Push ++ Rest,
    {done,{ok,yyrev(Ts, [T]),Line},NewRest};
tokens_cont(Rest, Line, skip_token, Ts) ->
    tokens(yystate(), Rest, Line, Rest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {skip_token,Push}, Ts) ->
    NewRest = Push ++ Rest,
    tokens(yystate(), NewRest, Line, NewRest, 0, Line, Ts, reject, 0);
tokens_cont(Rest, Line, {error,S}, _Ts) ->
    skip_tokens(Rest, Line, {Line,?MODULE,{user,S}}).

%%skip_tokens(InChars, Line, Error) -> {done,{error,Error,Line},Ics}.
%% Skip tokens until an end token, junk everything and return the error.

skip_tokens(Ics, Line, Error) ->
    skip_tokens(yystate(), Ics, Line, Ics, 0, Line, Error, reject, 0).

%% skip_tokens(State, InChars, Line, TokenChars, TokenLen, TokenLine, Tokens,
%% AcceptAction, AcceptLen) ->
%% {more,Continuation} | {done,ReturnVal,RestChars}.

skip_tokens(S0, Ics0, L0, Tcs, Tlen0, Tline, Error, A0, Alen0) ->
    case yystate(S0, Ics0, L0, Tlen0, A0, Alen0) of
        {A1,Alen1,Ics1,L1} ->                  % Accepting end state
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,[],L1,S1} ->                 % After an accepting state
            {more,{skip_tokens,S1,L1,Tcs,Alen1,Tline,Error,A1,Alen1}};
        {A1,Alen1,Ics1,L1,_S1} ->
            skip_cont(Ics1, L1, yyaction(A1, Alen1, Tcs, Tline), Error);
        {A1,Alen1,Tlen1,[],L1,S1} ->           % After a non-accepting state
            {more,{skip_tokens,S1,L1,Tcs,Tlen1,Tline,Error,A1,Alen1}};
        {reject,_Alen1,_Tlen1,eof,L1,_S1} ->
            {done,{error,Error,L1},eof};
        {reject,_Alen1,Tlen1,_Ics1,L1,_S1} ->
            skip_tokens(yysuf(Tcs, Tlen1+1), L1, Error);
        {A1,Alen1,_Tlen1,_Ics1,L1,_S1} ->
            Token = yyaction(A1, Alen1, Tcs, Tline),
            skip_cont(yysuf(Tcs, Alen1), L1, Token, Error)
    end.

%% skip_cont(RestChars, Line, Token, Error)
%% Skip tokens until we have an end_token or error then return done
%% with the original rror.

-dialyzer({nowarn_function, skip_cont/4}).

skip_cont(Rest, Line, {token,_T}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {end_token,_T}, Error) ->
    {done,{error,Error,Line},Rest};
skip_cont(Rest, Line, {end_token,_T,Push}, Error) ->
    NewRest = Push ++ Rest,
    {done,{error,Error,Line},NewRest};
skip_cont(Rest, Line, skip_token, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {skip_token,Push}, Error) ->
    NewRest = Push ++ Rest,
    skip_tokens(yystate(), NewRest, Line, NewRest, 0, Line, Error, reject, 0);
skip_cont(Rest, Line, {error,_S}, Error) ->
    skip_tokens(yystate(), Rest, Line, Rest, 0, Line, Error, reject, 0).

yyrev(List) -> lists:reverse(List).
yyrev(List, Tail) -> lists:reverse(List, Tail).
yypre(List, N) -> lists:sublist(List, N).
yysuf(List, N) -> lists:nthtail(N, List).

%% yystate() -> InitialState.
%% yystate(State, InChars, Line, CurrTokLen, AcceptAction, AcceptLen) ->
%% {Action, AcceptLen, RestChars, Line} |
%% {Action, AcceptLen, RestChars, Line, State} |
%% {reject, AcceptLen, CurrTokLen, RestChars, Line, State} |
%% {Action, AcceptLen, CurrTokLen, RestChars, Line, State}.
%% Generated state transition functions. The non-accepting end state
%% return signal either an unrecognised character or end of current
%% input.

-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.erl", 307).
yystate() -> 16.

yystate(19, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(19, Ics, Line, Tlen+1, 10, Tlen);
yystate(19, [C|Ics], Line, Tlen, _, _) when C >= 11 ->
    yystate(19, Ics, Line, Tlen+1, 10, Tlen);
yystate(19, Ics, Line, Tlen, _, _) ->
    {10,Tlen,Ics,Line,19};
yystate(18, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, [33|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, [10|Ics], Line, Tlen, _, _) ->
    yystate(10, Ics, Line+1, Tlen+1, 9, Tlen);
yystate(18, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(18, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 32 ->
    yystate(18, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 58 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(18, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line,18};
yystate(17, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [58|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [47|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [46|Ics], Line, Tlen, _, _) ->
    yystate(13, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 45 ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(17, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 6, Tlen);
yystate(17, Ics, Line, Tlen, _, _) ->
    {6,Tlen,Ics,Line,17};
yystate(16, [93|Ics], Line, Tlen, Action, Alen) ->
    yystate(12, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [92|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [91|Ics], Line, Tlen, Action, Alen) ->
    yystate(8, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [61|Ics], Line, Tlen, Action, Alen) ->
    yystate(15, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [60|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [59|Ics], Line, Tlen, Action, Alen) ->
    yystate(19, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [58|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(5, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [33|Ics], Line, Tlen, Action, Alen) ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [32|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [10|Ics], Line, Tlen, Action, Alen) ->
    yystate(10, Ics, Line+1, Tlen+1, Action, Alen);
yystate(16, [9|Ics], Line, Tlen, Action, Alen) ->
    yystate(14, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(18, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 31 ->
    yystate(18, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 35, C =< 47 ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 48, C =< 57 ->
    yystate(17, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 62, C =< 64 ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 65, C =< 90 ->
    yystate(4, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 94, C =< 96 ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 97, C =< 122 ->
    yystate(4, Ics, Line, Tlen+1, Action, Alen);
yystate(16, [C|Ics], Line, Tlen, Action, Alen) when C >= 123 ->
    yystate(6, Ics, Line, Tlen+1, Action, Alen);
yystate(16, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,16};
yystate(15, Ics, Line, Tlen, _, _) ->
    {0,Tlen,Ics,Line};
yystate(14, [91|Ics], Line, Tlen, _, _) ->
    yystate(8, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [58|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [34|Ics], Line, Tlen, _, _) ->
    yystate(5, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [33|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [32|Ics], Line, Tlen, _, _) ->
    yystate(14, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [10|Ics], Line, Tlen, _, _) ->
    yystate(10, Ics, Line+1, Tlen+1, 9, Tlen);
yystate(14, [9|Ics], Line, Tlen, _, _) ->
    yystate(14, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(18, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 31 ->
    yystate(18, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 47 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(17, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 64 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 92, C =< 96 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, [C|Ics], Line, Tlen, _, _) when C >= 123 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(14, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line,14};
yystate(13, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [58|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 47 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(13, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line,13};
yystate(12, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 1, Tlen);
yystate(12, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 1, Tlen);
yystate(12, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 1, Tlen);
yystate(12, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 58 ->
    yystate(6, Ics, Line, Tlen+1, 1, Tlen);
yystate(12, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 1, Tlen);
yystate(12, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 1, Tlen);
yystate(12, Ics, Line, Tlen, _, _) ->
    {1,Tlen,Ics,Line,12};
yystate(11, [93|Ics], Line, Tlen, _, _) ->
    yystate(3, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [92|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [61|Ics], Line, Tlen, _, _) ->
    yystate(7, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [33|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [32|Ics], Line, Tlen, _, _) ->
    yystate(11, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [9|Ics], Line, Tlen, _, _) ->
    yystate(11, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 8 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 31 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 58 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, [C|Ics], Line, Tlen, _, _) when C >= 94 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(11, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line,11};
yystate(10, [10|Ics], Line, Tlen, _, _) ->
    yystate(10, Ics, Line+1, Tlen+1, 11, Tlen);
yystate(10, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(10, Ics, Line, Tlen+1, 11, Tlen);
yystate(10, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 32 ->
    yystate(10, Ics, Line, Tlen+1, 11, Tlen);
yystate(10, Ics, Line, Tlen, _, _) ->
    {11,Tlen,Ics,Line,10};
yystate(9, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [58|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 47 ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(9, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 7, Tlen);
yystate(9, Ics, Line, Tlen, _, _) ->
    {7,Tlen,Ics,Line,9};
yystate(8, Ics, Line, Tlen, _, _) ->
    {2,Tlen,Ics,Line};
yystate(7, Ics, Line, Tlen, _, _) ->
    {4,Tlen,Ics,Line};
yystate(6, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(6, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(6, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(6, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 58 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(6, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(6, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(6, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line,6};
yystate(5, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(5, [C|Ics], Line, Tlen, Action, Alen) when C >= 11 ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(5, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,5};
yystate(4, [96|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [95|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [64|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [62|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [63|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [58|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [47|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [45|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [46|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 44 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(0, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(0, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 92, C =< 94 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(0, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, [C|Ics], Line, Tlen, _, _) when C >= 123 ->
    yystate(6, Ics, Line, Tlen+1, 9, Tlen);
yystate(4, Ics, Line, Tlen, _, _) ->
    {9,Tlen,Ics,Line,4};
yystate(3, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 3, Tlen);
yystate(3, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(6, Ics, Line, Tlen+1, 3, Tlen);
yystate(3, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(6, Ics, Line, Tlen+1, 3, Tlen);
yystate(3, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 58 ->
    yystate(6, Ics, Line, Tlen+1, 3, Tlen);
yystate(3, [C|Ics], Line, Tlen, _, _) when C >= 62, C =< 90 ->
    yystate(6, Ics, Line, Tlen+1, 3, Tlen);
yystate(3, [C|Ics], Line, Tlen, _, _) when C >= 92 ->
    yystate(6, Ics, Line, Tlen+1, 3, Tlen);
yystate(3, Ics, Line, Tlen, _, _) ->
    {3,Tlen,Ics,Line,3};
yystate(2, [34|Ics], Line, Tlen, _, _) ->
    yystate(2, Ics, Line, Tlen+1, 8, Tlen);
yystate(2, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 9 ->
    yystate(1, Ics, Line, Tlen+1, 8, Tlen);
yystate(2, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 33 ->
    yystate(1, Ics, Line, Tlen+1, 8, Tlen);
yystate(2, [C|Ics], Line, Tlen, _, _) when C >= 35 ->
    yystate(1, Ics, Line, Tlen+1, 8, Tlen);
yystate(2, Ics, Line, Tlen, _, _) ->
    {8,Tlen,Ics,Line,2};
yystate(1, [34|Ics], Line, Tlen, Action, Alen) ->
    yystate(2, Ics, Line, Tlen+1, Action, Alen);
yystate(1, [C|Ics], Line, Tlen, Action, Alen) when C >= 0, C =< 9 ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(1, [C|Ics], Line, Tlen, Action, Alen) when C >= 11, C =< 33 ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(1, [C|Ics], Line, Tlen, Action, Alen) when C >= 35 ->
    yystate(1, Ics, Line, Tlen+1, Action, Alen);
yystate(1, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,1};
yystate(0, [96|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [95|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [94|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [93|Ics], Line, Tlen, _, _) ->
    yystate(3, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [92|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [64|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [62|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [63|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [61|Ics], Line, Tlen, _, _) ->
    yystate(7, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [60|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [58|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [47|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [45|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [46|Ics], Line, Tlen, _, _) ->
    yystate(4, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [33|Ics], Line, Tlen, _, _) ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [32|Ics], Line, Tlen, _, _) ->
    yystate(11, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [9|Ics], Line, Tlen, _, _) ->
    yystate(11, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 0, C =< 8 ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 11, C =< 31 ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 35, C =< 44 ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 48, C =< 57 ->
    yystate(0, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 65, C =< 90 ->
    yystate(0, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 97, C =< 122 ->
    yystate(0, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, [C|Ics], Line, Tlen, _, _) when C >= 123 ->
    yystate(6, Ics, Line, Tlen+1, 5, Tlen);
yystate(0, Ics, Line, Tlen, _, _) ->
    {5,Tlen,Ics,Line,0};
yystate(S, Ics, Line, Tlen, Action, Alen) ->
    {Action,Alen,Tlen,Ics,Line,S}.

%% yyaction(Action, TokenLength, TokenChars, TokenLine) ->
%% {token,Token} | {end_token, Token} | skip_token | {error,String}.
%% Generated action function.

yyaction(0, _, _, TokenLine) ->
    yyaction_0(TokenLine);
yyaction(1, _, _, TokenLine) ->
    yyaction_1(TokenLine);
yyaction(2, _, _, TokenLine) ->
    yyaction_2(TokenLine);
yyaction(3, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_3(TokenChars, TokenLen, TokenLine);
yyaction(4, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_4(TokenChars, TokenLen, TokenLine);
yyaction(5, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_5(TokenChars, TokenLine);
yyaction(6, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_6(TokenChars, TokenLine);
yyaction(7, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_7(TokenChars, TokenLine);
yyaction(8, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_8(TokenChars, TokenLine);
yyaction(9, TokenLen, YYtcs, TokenLine) ->
    TokenChars = yypre(YYtcs, TokenLen),
    yyaction_9(TokenChars, TokenLine);
yyaction(10, _, _, _) ->
    yyaction_10();
yyaction(11, _, _, _) ->
    yyaction_11();
yyaction(_, _, _, _) -> error.

-compile({inline,yyaction_0/1}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 7).
yyaction_0(TokenLine) ->
     { token, { '=', TokenLine } } .

-compile({inline,yyaction_1/1}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 8).
yyaction_1(TokenLine) ->
     { token, { ']', TokenLine } } .

-compile({inline,yyaction_2/1}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 9).
yyaction_2(TokenLine) ->
     { token, { '[', TokenLine } } .

-compile({inline,yyaction_3/3}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 10).
yyaction_3(TokenChars, TokenLen, TokenLine) ->
     { token, { key, TokenLine, to_key (TokenChars, TokenLen) }, "]" } .

-compile({inline,yyaction_4/3}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 11).
yyaction_4(TokenChars, TokenLen, TokenLine) ->
     { token, { key, TokenLine, to_key (TokenChars, TokenLen) }, "=" } .

-compile({inline,yyaction_5/2}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 12).
yyaction_5(TokenChars, TokenLine) ->
     { token, { value, TokenLine, to_atom (TokenChars) } } .

-compile({inline,yyaction_6/2}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 13).
yyaction_6(TokenChars, TokenLine) ->
     { token, { value, TokenLine, to_integer (TokenChars) } } .

-compile({inline,yyaction_7/2}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 14).
yyaction_7(TokenChars, TokenLine) ->
     { token, { value, TokenLine, to_float (TokenChars) } } .

-compile({inline,yyaction_8/2}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 15).
yyaction_8(TokenChars, TokenLine) ->
     { token, { value, TokenLine, to_string (TokenChars) } } .

-compile({inline,yyaction_9/2}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 16).
yyaction_9(TokenChars, TokenLine) ->
     { token, { value, TokenLine, string : strip (TokenChars) } } .

-compile({inline,yyaction_10/0}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 17).
yyaction_10() ->
     skip_token .

-compile({inline,yyaction_11/0}).
-file("/Users/mm/install/rust_demo/nodes/node1/_build/default/lib/zucchini/src/zucchini_lexer.xrl", 18).
yyaction_11() ->
     skip_token .

-file("/usr/local/erlang_18.3/lib/erlang/lib/parsetools-2.1.1/include/leexinc.hrl", 290).
