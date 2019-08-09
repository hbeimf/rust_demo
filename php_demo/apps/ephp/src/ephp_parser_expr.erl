-module(ephp_parser_expr).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-export([expression/3, add_op/2, precedence/1]).

-include("ephp.hrl").
-include("ephp_parser.hrl").

-import(ephp_parser, [
    add_pos/2, new_line/1, copy_level/2, add_line/2, remove_spaces/2,
    throw_error/3,

    array_def_level/1, code_statement_level/1, arg_level/1,
    enclosed_level/1,

    variable/3, comment_line/3, comment_block/3, constant/3
]).

-import(ephp_parser_func, [
    st_use_or_block/3, funct_name/3
]).

array_def_54_level({_,Row,Col}) -> {{array_def,54},Row,Col}.

add_op('end', []) ->
    [];
add_op('end', [{op, [#constant{name = Name, line = Pos} = Constant]}]) ->
    Op = case Name of
        <<I:8,N:8,T:8>> when ?OR(I,$i,$I) andalso ?OR(N,$n,$N) andalso
                             ?OR(T,$t,$T) ->
            OpL = <<"(int)">>,
            {OpL, precedence(OpL), Pos};
        <<I:8,N:8,T:8,E:8,G:8,E:8,R:8>> when ?OR(I,$i,$I) andalso ?OR(N,$n,$N)
                                     andalso ?OR(T,$t,$T) andalso ?OR(E,$e,$E)
                                     andalso ?OR(G,$g,$G) andalso ?OR(R,$r,$R) ->
            OpL = <<"(int)">>,
            {OpL, precedence(OpL), Pos};
        <<F:8,L:8,O:8,A:8,T:8>> when ?OR(F,$F,$f) andalso ?OR(L,$L,$l) andalso
                                     ?OR(O,$O,$o) andalso ?OR(A,$A,$a) andalso
                                     ?OR(T,$T,$t) ->
            OpL = <<"(float)">>,
            {OpL, precedence(OpL), Pos};
        <<D:8,O:8,U:8,B:8,L:8,E:8>> when ?OR(D,$D,$d) andalso ?OR(O,$O,$o)
                                 andalso ?OR(U,$U,$u) andalso ?OR(B,$B,$b)
                                 andalso ?OR(L,$L,$l) andalso ?OR(E,$E,$e) ->
            OpL = <<"(float)">>,
            {OpL, precedence(OpL), Pos};
        <<S:8,T:8,R:8,I:8,N:8,G:8>> when ?OR(S,$S,$s) andalso
                                         ?OR(T,$T,$t) andalso
                                         ?OR(R,$R,$r) andalso
                                         ?OR(I,$I,$i) andalso
                                         ?OR(N,$N,$n) andalso
                                         ?OR(G,$G,$g) ->
            OpL = <<"(string)">>,
            {OpL, precedence(OpL), Pos};
        % array will be captured in the array() part
        <<O:8,B:8,J:8,E:8,C:8,T:8>> when ?OR(O,$O,$o) andalso
                                         ?OR(B,$B,$b) andalso
                                         ?OR(J,$J,$j) andalso
                                         ?OR(E,$E,$e) andalso
                                         ?OR(C,$C,$c) andalso
                                         ?OR(T,$T,$t) ->
            OpL = <<"(object)">>,
            {OpL, precedence(OpL), Pos};
        <<B:8,O:8,O:8,L:8,E:8,A:8,N:8>> when ?OR(B,$B,$b) andalso
                                             ?OR(O,$O,$o) andalso
                                             ?OR(L,$L,$l) andalso
                                             ?OR(E,$E,$e) andalso
                                             ?OR(A,$A,$a) andalso
                                             ?OR(N,$N,$n) ->
            OpL = <<"(bool)">>,
            {OpL, precedence(OpL), Pos};
        <<B:8,O:8,O:8,L:8>> when ?OR(B,$B,$b) andalso ?OR(O,$O,$o) andalso
                                 ?OR(L,$L,$l) ->
            OpL = <<"(bool)">>,
            {OpL, precedence(OpL), Pos};
        <<U:8,N:8,S:8,E:8,T:8>> when ?OR(U,$U,$u) andalso ?OR(N,$N,$n) andalso
                                     ?OR(S,$S,$s) andalso ?OR(E,$E,$e) andalso
                                     ?OR(T,$T,$t) ->
            OpL = <<"(unset)">>,
            {OpL, precedence(OpL), Pos};
        _ ->
            Constant
    end,
    solve([Op]);
add_op('end', [{op,Content}]) ->
    solve(process_incr_decr(Content));
add_op(Add, [{op,Content}|Parsed]) when is_list(Add) ->
    [{op, Content ++ Add}|Parsed];
add_op(Add, [{op,Content}|Parsed]) ->
    [{op, Content ++ [Add]}|Parsed];
add_op(Add, Parsed) ->
    [{op,[Add]}|Parsed].

process_incr_decr(Content) ->
    process_incr_decr(Content, []).

process_incr_decr([], Processed) ->
    Processed;
process_incr_decr([{<<"++">>,_,Pos},#variable{}=V|Rest], Processed) ->
    process_incr_decr(Rest, Processed ++ [{pre_incr, V, Pos}]);
process_incr_decr([{<<"--">>,_,Pos},#variable{}=V|Rest], Processed) ->
    process_incr_decr(Rest, Processed ++ [{pre_decr, V, Pos}]);
process_incr_decr([#variable{}=V,{<<"++">>,_,Pos}|Rest], Processed) ->
    process_incr_decr(Rest, Processed ++ [{post_incr, V, Pos}]);
process_incr_decr([#variable{}=V,{<<"--">>,_,Pos}|Rest], Processed) ->
    process_incr_decr(Rest, Processed ++ [{post_decr, V, Pos}]);
process_incr_decr([A|Rest], Processed) ->
    process_incr_decr(Rest, Processed ++ [A]).

number(<<"0", X:8, Rest/binary>>, Pos, []) when ?OR(X, $X, $x) ->
    hexa(Rest, add_pos(Pos, 2), []);
number(<<"0", N:8, Rest/binary>>, Pos, []) when ?IS_OCT(N) ->
    octa(<<N:8, Rest/binary>>, add_pos(Pos, 2), []);
number(<<A:8, Rest/binary>>, Pos, []) when ?IS_NUMBER(A) orelse A =:= $- ->
    number(Rest, add_pos(Pos, 1), [add_line(#int{int = <<A:8>>}, Pos)]);
number(<<A:8, Rest/binary>>, Pos, [#int{int = N} = I]) when ?IS_NUMBER(A) ->
    number(Rest, add_pos(Pos, 1), [I#int{int = <<N/binary,A:8>>}]);
number(<<".", Rest/binary>>, Pos, []) ->
    number(Rest, add_pos(Pos, 1), [add_line(#float{float = <<"0.">>}, Pos)]);
number(<<".", Rest/binary>>, Pos, [#int{int = N, line = Line}]) ->
    number(Rest, add_pos(Pos, 1), [#float{float = <<N/binary,".">>, line = Line}]);
number(<<A:8, Rest/binary>>, Pos, [#float{float = N} = F]) when ?IS_NUMBER(A) ->
    number(Rest, add_pos(Pos, 1), [F#float{float = <<N/binary, A:8>>}]);
number(Rest, Pos, [#int{int = N} = I]) ->
    {Rest, Pos, [I#int{int = binary_to_integer(N)}]};
number(Rest, Pos, [#float{float = N} = F]) ->
    {Rest, Pos, [F#float{float = binary_to_float(N)}]}.

hexa(<<A:8,Rest/binary>>, Pos, []) when ?IS_HEX(A) ->
    hexa(Rest, add_pos(Pos, 1), [add_line(#int{int = <<A:8>>}, Pos)]);
hexa(<<A:8,Rest/binary>>, Pos, [#int{int=N}=I]) when ?IS_HEX(A) ->
    hexa(Rest, add_pos(Pos, 1), [I#int{int = <<N/binary, A:8>>}]);
hexa(Rest, Pos, [#int{int = N} = I]) ->
    {Rest, Pos, [I#int{int = binary_to_integer(N, 16)}]}.

octa(<<A:8,Rest/binary>>, Pos, []) when ?IS_OCT(A) ->
    octa(Rest, add_pos(Pos, 1), [add_line(#int{int = <<A:8>>}, Pos)]);
octa(<<A:8,Rest/binary>>, Pos, [#int{int=N}=I]) when ?IS_OCT(A) ->
    octa(Rest, add_pos(Pos, 1), [I#int{int = <<N/binary, A:8>>}]);
octa(Rest, Pos, [#int{int = N} = I]) ->
    {Rest, Pos, [I#int{int = binary_to_integer(N, 8)}]}.

array_def(<<SP:8,Rest/binary>>, Pos, Args) when ?IS_SPACE(SP) ->
    array_def(Rest, add_pos(Pos,1), Args);
array_def(<<SP:8,Rest/binary>>, Pos, Args) when ?IS_NEWLINE(SP) ->
    array_def(Rest, new_line(Pos), Args);
array_def(<<")",Rest/binary>>, {{array_def,0},_,_}=Pos, Args) ->
    {Rest,add_pos(Pos,1),Args};
array_def(<<"]",Rest/binary>>, {{array_def,54},_,_}=Pos, Args) ->
    {Rest,add_pos(Pos,1),Args};
%% TODO add error missing closing params
array_def(Rest, Pos, Args) when Rest =/= <<>> ->
    case expression(Rest, Pos, []) of
        {<<")",Rest0/binary>>, {{array_def,0},_,_}=Pos0, [Idx,Arg]} ->
            NewArg = add_line(#array_element{idx=Idx, element=Arg}, Pos),
            {Rest0, add_pos(Pos0,1), Args ++ [NewArg]};
        {<<")",Rest0/binary>>, {{array_def,0},_,_}=Pos0, undefined} ->
            {Rest0, add_pos(Pos0,1), Args};
        {<<")",Rest0/binary>>, {{array_def,0},_,_}=Pos0, Arg} ->
            NewArg = add_line(#array_element{element=Arg}, Pos),
            {Rest0, add_pos(Pos0,1), Args ++ [NewArg]};
        {<<"]",Rest0/binary>>, {{array_def,54},_,_}=Pos0, [Idx,Arg]} ->
            NewArg = add_line(#array_element{idx=Idx, element=Arg}, Pos),
            {Rest0, add_pos(Pos0,1), Args ++ [NewArg]};
        {<<"]",Rest0/binary>>, {{array_def,54},_,_}=Pos0, undefined} ->
            {Rest0, add_pos(Pos0,1), Args};
        {<<"]",Rest0/binary>>, {{array_def,54},_,_}=Pos0, Arg} ->
            NewArg = add_line(#array_element{element=Arg}, Pos),
            {Rest0, add_pos(Pos0,1), Args ++ [NewArg]};
        {<<",",Rest0/binary>>, Pos0, [Idx,Arg]} ->
            NewArg = add_line(#array_element{idx=Idx, element=Arg}, Pos),
            array_def(Rest0, add_pos(Pos0, 1), Args ++ [NewArg]);
        {<<",",Rest0/binary>>, Pos0, Arg} ->
            NewArg = add_line(#array_element{element=Arg}, Pos),
            array_def(Rest0, add_pos(Pos0, 1), Args ++ [NewArg])
    end.

% CONSTANT / FUNCTION when -> is used
expression(<<A:8,_/binary>> = Rest, Pos,
           [{op,[_,{<<"->">>,_,_}]}|_]=Parsed) when
        ?IS_ALPHA(A) orelse A =:= $_ ->
    {Rest0, Pos0, [Constant]} = constant(Rest, Pos, []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Constant, Parsed));
% ARRAY(...) -old-
expression(<<A:8,R:8,R:8,A:8,Y:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(A,$a,$A) andalso ?OR(R,$r,$R) andalso ?OR(Y,$y,$Y)
        andalso not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_) ->
    case remove_spaces(<<SP:8, Rest/binary>>, add_pos(Pos, 5)) of
        {<<")", _/binary>> = Rest0, Pos0} ->
            %% (array) cast
            OpL = <<"(array)">>,
            NewParsed = add_op({OpL, precedence(OpL), Pos}, Parsed),
            expression(Rest0, Pos0, NewParsed);
        {<<"(", Rest0/binary>>, Pos0} ->
            NewPos = array_def_level(add_pos(Pos0, 1)),
            {Rest1, Pos1, Content} = array_def(Rest0, NewPos, []),
            NewParsed = add_op(add_line(#array{elements=Content}, Pos), Parsed),
            expression(Rest1, copy_level(Pos, Pos1), NewParsed)
    end;
% [...] -array new-
expression(<<"[",Rest/binary>>, Pos, []) ->
    NewPos = array_def_54_level(add_pos(Pos, 1)),
    {Rest1, Pos1, Content} = array_def(Rest, NewPos, []),
    NewParsed = add_op(add_line(#array{elements=Content}, Pos), []),
    expression(Rest1, copy_level(Pos, Pos1), NewParsed);
expression(<<"[",Rest/binary>>, Pos, [{op,[]}|_]=Parsed) ->
    % ARRAY DEF
    NewPos = array_def_54_level(add_pos(Pos, 1)),
    {Rest1, Pos1, Content} = array_def(Rest, NewPos, []),
    NewParsed = add_op(add_line(#array{elements=Content}, Pos), Parsed),
    expression(Rest1, copy_level(Pos, Pos1), NewParsed);
expression(<<"[",Rest/binary>>, Pos, [{op,Op}|_]=Parsed) ->
    case lists:last(Op) of
        {_,{RightOrLeft,_},_} when RightOrLeft =:= right orelse
                                   RightOrLeft =:= left ->
            % ARRAY DEF
            NewPos = array_def_54_level(add_pos(Pos, 1)),
            {Rest1, Pos1, Content} = array_def(Rest, NewPos, []),
            NewParsed = add_op(add_line(#array{elements=Content}, Pos), Parsed),
            expression(Rest1, copy_level(Pos, Pos1), NewParsed);
        _ ->
            % ARRAY INDEX
            NewParsed = [#variable{name = add_op('end', Parsed)}],
            {Rest0, Pos0, [Parsed0]} =
                variable(<<"[",Rest/binary>>, Pos, NewParsed),
            expression(Rest0, Pos0, add_op(Parsed0, []))
    end;
% NULL
expression(<<N:8,U:8,L:8,L:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(N,$N,$n) andalso ?OR(U,$U,$u) andalso ?OR(L,$L,$l)
        andalso not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_) ->
    expression(<<SP:8,Rest/binary>>, add_pos(Pos,4), add_op(undefined, Parsed));
% TRUE
expression(<<T:8,R:8,U:8,E:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(T,$t,$T) andalso ?OR(R,$r,$R) andalso ?OR(U,$u,$U)
        andalso ?OR(E,$e,$E)
        andalso not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_) ->
    expression(<<SP:8,Rest/binary>>, add_pos(Pos,4), add_op(true, Parsed));
% FALSE
expression(<<F:8,A:8,L:8,S:8,E:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(F,$f,$F) andalso ?OR(A,$a,$A) andalso ?OR(L,$l,$L)
        andalso ?OR(S,$s,$S) andalso ?OR(E,$e,$E)
        andalso not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_) ->
    expression(<<SP:8,Rest/binary>>, add_pos(Pos,5), add_op(false, Parsed));
% FUNCTION(...) -closure-
expression(<<F:8,U:8,N:8,C:8,T:8,I:8,O:8,N:8,SP:8,Rest/binary>>,
           Pos, Parsed) when
        ?OR(F,$F,$f) andalso ?OR(U,$U,$u) andalso ?OR(N,$N,$n) andalso
        ?OR(C,$C,$c) andalso ?OR(T,$T,$t) andalso ?OR(I,$I,$i) andalso
        ?OR(O,$O,$o) andalso
        (?IS_SPACE(SP) orelse ?IS_NEWLINE(SP) orelse SP =:= $() ->
    {<<"(",Rest0/binary>>, Pos0} =
        remove_spaces(<<SP:8,Rest/binary>>, add_pos(Pos, 9)),
    {Rest1, Pos1, Args} = ephp_parser_func:funct_args(Rest0, Pos0, []),
    BaseFunction = add_line(#function{args = Args}, Pos),
    {Rest2, Pos2, Function} = st_use_or_block(Rest1, Pos1, BaseFunction),
    expression(Rest2, copy_level(Pos, Pos2), add_op(Function, Parsed));
% INSTANCEOF
expression(<<I:8,N:8,S:8,T:8,A:8,N:8,C:8,E:8,O:8,F:8,SP:8,Rest/binary>>,
           Pos, Parsed) when
        ?OR(I,$I,$i) andalso ?OR(N,$N,$n) andalso ?OR(S,$S,$s) andalso
        ?OR(T,$T,$t) andalso ?OR(A,$A,$a) andalso ?OR(C,$C,$c) andalso
        ?OR(E,$E,$e) andalso ?OR(O,$O,$o) andalso ?OR(F,$F,$f) andalso
        (?IS_SPACE(SP) orelse ?IS_NEWLINE(SP)) ->
    {Rest0, Pos0} = remove_spaces(<<SP:8,Rest/binary>>, Pos),
    OpL = <<"instanceof">>,
    expression(Rest0, Pos0, add_op({instanceof, precedence(OpL), Pos}, Parsed));
% NEW ...
expression(<<N:8,E:8,W:8,SP:8,Rest/binary>>, Pos, Parsed) when
        ?OR(N,$N,$n) andalso ?OR(E,$E,$e) andalso ?OR(W,$W,$w) andalso
        (?IS_SPACE(SP) orelse ?IS_NEWLINE(SP) orelse SP =:= $() ->
    {Rest1, Pos1, ObjName} = case remove_spaces(<<SP:8,Rest/binary>>, Pos) of
        {<<"$", _/binary>> = Rest0, Pos0} ->
            expression(Rest0, Pos0, []);
        {<<A:8, _/binary>> = Rest0, Pos0} when ?IS_ALPHA(A) orelse A =:= $_ ->
            funct_name(Rest0, Pos0, [])
    end,
    Instance = case remove_spaces(Rest1, Pos1) of
        {<<"(",Rest2/binary>>, Pos2} ->
            {Rest3, Pos3, Args} = ephp_parser_func:call_args(Rest2, Pos2, []),
            add_line(#instance{name = ObjName, args = Args}, Pos);
        {Rest3, Pos3} ->
            add_line(#instance{name = ObjName}, Pos)
    end,
    expression(Rest3, copy_level(Pos, Pos3), add_op(Instance,Parsed));
% CLONE ...
expression(<<C:8,L:8,O:8,N:8,E:8,SP:8,Rest/binary>>, Pos, Parsed) when
        ?OR(C,$C,$c) andalso ?OR(L,$L,$l) andalso ?OR(O,$O,$o) andalso
        ?OR(N,$N,$n) andalso ?OR(E,$E,$e) andalso
        (?IS_SPACE(SP) orelse ?IS_NEWLINE(SP) orelse SP =:= $() ->
    OpL = <<"clone">>,
    Pos1 = add_pos(Pos, 5),
    Rest1 = <<SP:8, Rest/binary>>,
    expression(Rest1, Pos1, add_op({OpL, precedence(OpL), Pos}, Parsed));
% FINAL -enclosed-
expression(<<"}",Rest/binary>>, {enclosed,_,_}=Pos, [Exp]) ->
    {Rest, add_pos(Pos,1), add_op('end', [Exp])};
% FINAL -unclosed-
expression(<<SP:8,_/binary>> = Rest, {unclosed,_,_}=Pos, [Exp])
        when ?IS_SPACE(SP) orelse SP =:= $" ->
    {Rest, Pos, add_op('end', [Exp])};
% SPACE -all-
expression(<<SP:8,Rest/binary>>, Pos, Parsed) when ?IS_SPACE(SP) ->
    expression(Rest, add_pos(Pos,1), Parsed);
% NEWLINE -all-
expression(<<SP:8,Rest/binary>>, Pos, Parsed) when ?IS_NEWLINE(SP) ->
    expression(Rest, new_line(Pos), Parsed);
% COMMENTS...
expression(<<"//",Rest/binary>>, Pos, Parsed) ->
    {Rest0, Pos0, _} = comment_line(Rest, Pos, Parsed),
    expression(Rest0, Pos0, Parsed);
expression(<<"#",Rest/binary>>, Pos, Parsed) ->
    {Rest0, Pos0, _} = comment_line(Rest, Pos, Parsed),
    expression(Rest0, Pos0, Parsed);
expression(<<"/*",Rest/binary>>, Pos, Parsed) ->
    {Rest0, Pos0, _} = comment_block(Rest, Pos, Parsed),
    expression(Rest0, Pos0, Parsed);
% FUNCTION CALL
expression(<<"(",Rest/binary>>, Pos, [{op, Op}|Parsed]) ->
    {Op1, Op2} = case length(Op) of
        Size when Size >= 2 ->
            lists:split(Size - 1, Op);
        1 ->
            {[], Op};
        0 ->
            {[], []}
    end,
    case Op2 of
        [#variable{} = V] ->
            Call = #call{name = V, line = V#variable.line},
            {Rest0, Pos0, [Function]} =
                ephp_parser_func:function(Rest, add_pos(Pos,1), [Call|Parsed]),
            NewOp = {op, Op1 ++ [Function]},
            expression(Rest0, copy_level(Pos, Pos0), [NewOp|Parsed]);
        _ ->
            exp_parens(Rest, add_pos(Pos, 1), [{op, Op}|Parsed])
    end;
% PARENS
expression(<<"(", Rest/binary>>, Pos, Parsed) ->
    % FIXME: this is inconsistent, sometimes is expecting to remove ")"
    %        and sometimes is not.
    exp_parens(Rest, Pos, Parsed);
% FINAL -arg-
expression(<<",", _/binary>> = Rest, {array, _, _} = Pos, Parsed) ->
    {Rest, Pos, add_op('end', Parsed)};
expression(<<",", _/binary>> = Rest, {array_curly, _, _} = Pos, Parsed) ->
    {Rest, Pos, add_op('end', Parsed)};
expression(<<A:8,_/binary>> = Rest, {arg,_,_}=Pos, [{op,_},#if_block{}|_])
        when A =:= $, orelse A =:= $) ->
    throw_error(eparse, Pos, Rest);
expression(<<A:8,_/binary>> = Rest, {arg,_,_}=Pos, Parsed)
        when A =:= $, orelse A =:= $) ->
    case add_op('end', Parsed) of
        #operation{type = <<"?">>, line={{_,R},{_,C}}} ->
            throw_error(eparse, {arg,R,C}, Rest);
        Op ->
            {Rest, Pos, Op}
    end;
% FINAL -array definition array(...)-
expression(<<A:8,_/binary>> = Rest, {{array_def,0},_,_}=Pos,
           [{op,_},#if_block{}|_])
        when A =:= $, orelse A =:= $) ->
    throw_error(eparse, Pos, Rest);
expression(<<A:8,_/binary>> = Rest, {{array_def,0},_,_}=Pos, [Parsed])
        when A =:= $, orelse A =:= $) ->
    {Rest, Pos, add_op('end', [Parsed])};
expression(<<A:8,_/binary>> = Rest, {{array_def,0},_,_}=Pos, Parsed)
        when A =:= $, orelse A =:= $) ->
    case Parsed of
        [Arg, Idx] -> {Rest, Pos, [Idx, add_op('end', [Arg])]};
        [] -> {Rest, Pos, undefined}
    end;
% FINAL -array definition [...]-
expression(<<A:8,_/binary>> = Rest, {{array_def,54},_,_}=Pos,
           [{op,_},#if_block{}|_])
        when A =:= $, orelse A =:= $] ->
    throw_error(eparse, Pos, Rest);
expression(<<A:8,_/binary>> = Rest, {{array_def,54},_,_}=Pos, [Parsed])
        when A =:= $, orelse A =:= $] ->
    {Rest, Pos, add_op('end', [Parsed])};
expression(<<A:8,_/binary>> = Rest, {{array_def,54},_,_}=Pos, Parsed)
        when A =:= $, orelse A =:= $] ->
    case Parsed of
        [Arg,Idx] -> {Rest, Pos, [Idx,add_op('end', [Arg])]};
        [] -> {Rest, Pos, undefined}
    end;
% KEY & VALUE -array_def old and new-
expression(<<"=>",Rest/binary>>, {{array_def,_},_,_}=Pos, [{op,_}=Op|Parser]) ->
    expression(Rest, add_pos(Pos,2), [{op,[]},add_op('end', [Op])|Parser]);
% FINAL -all but parens-
expression(<<A:8,_/binary>> = Rest, {L,_,_}=Pos, [{op,_},#if_block{}|_])
        when not is_number(L) andalso (A =:= $) orelse A =:= $;) ->
    throw_error(eparse, Pos, Rest);
expression(<<A:8,_/binary>> = Rest, {L,_,_}=Pos, Parsed)
        when not is_number(L) andalso (A =:= $) orelse A =:= $;) ->
    {Rest, Pos, add_op('end', Parsed)};
% FOREACH DATA
expression(<<A:8,S:8,SP:8,_/binary>> = Rest, {foreach_block,_,_} = Pos,
           [{op,_},#if_block{}|_])
        when ?OR(A,$a,$A) andalso ?OR(S,$s,$S) andalso
        not (?IS_ALPHANUM(SP) orelse SP =:= $_ orelse SP =:= $() ->
    throw_error(eparse, Pos, Rest);
expression(<<A:8,S:8,SP:8,_/binary>> = Rest, {foreach_block,_,_} = Pos, Parsed)
        when ?OR(A,$a,$A) andalso ?OR(S,$s,$S) andalso
        not (?IS_ALPHANUM(SP) orelse SP =:= $_ orelse SP =:= $() ->
    {Rest, Pos, add_op('end', Parsed)};
% FINAL -parens-
expression(<<")",_/binary>> = Rest, {L,_Row,_Col}=Pos, [{op,_},#if_block{}|_])
        when is_number(L) ->
    throw_error(eparse, Pos, Rest);
expression(<<")",Rest/binary>>, {L,_Row,_Col}=Pos, Parsed) when is_number(L) ->
    {Rest, add_pos(Pos,1), add_op('end', Parsed)};
% FINAL -array-
expression(<<"]",_/binary>> = Rest, {array,_,_} = Pos, [{op,_},#if_block{}|_]) ->
    throw_error(eparse, Pos, Rest);
expression(<<"]", Rest/binary>>, {array,_,_} = Pos, Parsed) ->
    {Rest, add_pos(Pos,1), add_op('end', Parsed)};
expression(<<"}",_/binary>> = Rest, {array_curly,_,_} = Pos,
           [{op, _}, #if_block{}|_]) ->
    throw_error(eparse, Pos, Rest);
expression(<<"}", Rest/binary>>, {array_curly,_,_} = Pos, Parsed) ->
    {Rest, add_pos(Pos,1), add_op('end', Parsed)};
% FINAL -all but parens-
expression(<<"?>\n",_/binary>> = Rest, {L,_,_} = Pos, [{op,_},#if_block{}|_])
        when not is_number(L) ->
    throw_error(eparse, Pos, Rest);
expression(<<"?>\n",_/binary>> = Rest, {L,_,_}=Pos, Parsed)
        when not is_number(L) ->
    case add_op('end', Parsed) of
        #operation{type = <<"?">>, line={{_,R},{_,C}}} ->
            throw_error(eparse, {L,R,C}, Rest);
        Op ->
            {Rest, Pos, Op}
    end;
expression(<<"?>",_/binary>> = Rest, {L,_,_}=Pos, [{op,_},#if_block{}|_])
        when not is_number(L) ->
    throw_error(eparse, Pos, Rest);
expression(<<"?>",_/binary>> = Rest, {L,_,_}=Pos, Parsed)
        when not is_number(L) ->
    {Rest, Pos, add_op('end', Parsed)};
% VARIABLE
expression(<<"$",Rest/binary>>, Pos, Parsed) ->
    {Rest0, Pos0, [Var]} = variable(Rest, add_pos(Pos,1), []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Var, Parsed));
% NUMBER
expression(<<A:8, _/binary>> = Rest, Pos, Parsed) when ?IS_NUMBER(A) ->
    {Rest0, Pos0, [Number]} = number(Rest, Pos, []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Number, Parsed));
expression(<<".", A:8, _/binary>> = Rest, Pos, Parsed) when ?IS_NUMBER(A) ->
    {Rest0, Pos0, [Number]} = number(Rest, Pos, []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Number, Parsed));
% STRING
expression(<<A:8,_/binary>> = Rest, Pos, Parsed) when
        A =:= $" orelse A =:= $' orelse A =:= $` ->
    {Rest0, Pos0, String} = ephp_parser_string:string(Rest, Pos, []),
    expression(Rest0, Pos0, add_op(String, Parsed));
% HEREDOC & NOWDOC
expression(<<"<<<",_/binary>> = Rest, Pos, Parsed) ->
    {Rest0, Pos0, String} = ephp_parser_string:string(Rest, Pos, []),
    expression(Rest0, Pos0, add_op(String, Parsed));
% INCLUDE
expression(<<I:8,N:8,C:8,L:8,U:8,D:8,E:8,SP:8,Rest/binary>>, Pos, Parsed) when
        ?OR(I,$I,$i) andalso ?OR(N,$N,$n) andalso ?OR(C,$C,$c) andalso
        ?OR(L,$L,$l) andalso ?OR(U,$U,$u) andalso ?OR(D,$D,$d) andalso
        ?OR(E,$E,$e) andalso
        (SP =:= $) orelse ?IS_SPACE(SP) orelse ?IS_NEWLINE(SP)) ->
    {Rest0, Pos0} = case remove_spaces(<<SP:8,Rest/binary>>, add_pos(Pos, 7)) of
        {<<"(",R0/binary>>, P0} ->
            {R0, add_pos(P0, 1)};
        {R0, P0} ->
            {R0, P0}
    end,
    {Rest1, Pos1, Exp} = expression(Rest0, Pos0, []),
    Include = add_line(#call{name = <<"include">>, args=[Exp]}, Pos),
    expression(Rest1, Pos1, add_op(Include, Parsed));
% INCLUDE_ONCE
expression(<<I:8,N:8,C:8,L:8,U:8,D:8,E:8,$_,O:8,N:8,C:8,E:8,SP:8,Rest/binary>>,
     Pos, Parsed) when
        ?OR(I,$I,$i) andalso ?OR(N,$N,$n) andalso ?OR(C,$C,$c) andalso
        ?OR(L,$L,$l) andalso ?OR(U,$U,$u) andalso ?OR(D,$D,$d) andalso
        ?OR(E,$E,$e) andalso ?OR(O,$O,$o) andalso
        (SP =:= $) orelse ?IS_SPACE(SP) orelse ?IS_NEWLINE(SP)) ->
    {Rest0, Pos0} = case remove_spaces(<<SP:8,Rest/binary>>, add_pos(Pos, 12)) of
        {<<"(",R0/binary>>, P0} ->
            {R0, add_pos(P0, 1)};
        {R0, P0} ->
            {R0, P0}
    end,
    {Rest1, Pos1, Exp} = expression(Rest0, Pos0, []),
    Include = add_line(#call{name = <<"include_once">>, args=[Exp]}, Pos),
    expression(Rest1, Pos1, add_op(Include, Parsed));
% REQUIRE
expression(<<R:8,E:8,Q:8,U:8,I:8,R:8,E:8,SP:8,Rest/binary>>, Pos, Parsed) when
        ?OR(R,$R,$r) andalso ?OR(E,$E,$e) andalso ?OR(Q,$Q,$q) andalso
        ?OR(U,$U,$u) andalso ?OR(I,$I,$i) andalso
        (SP =:= $) orelse ?IS_SPACE(SP) orelse ?IS_NEWLINE(SP)) ->
    {Rest0, Pos0} = case remove_spaces(<<SP:8,Rest/binary>>, add_pos(Pos, 7)) of
        {<<"(",R0/binary>>, P0} ->
            {R0, add_pos(P0, 1)};
        {R0, P0} ->
            {R0, P0}
    end,
    {Rest1, Pos1, Exp} = expression(Rest0, Pos0, []),
    Include = add_line(#call{name = <<"require">>, args=[Exp]}, Pos),
    expression(Rest1, Pos1, add_op(Include, Parsed));
% REQUIRE_ONCE
expression(<<R:8,E:8,Q:8,U:8,I:8,R:8,E:8,$_,O:8,N:8,C:8,E:8,SP:8,Rest/binary>>,
     Pos, Parsed) when
        ?OR(R,$R,$r) andalso ?OR(E,$E,$e) andalso ?OR(Q,$Q,$q) andalso
        ?OR(U,$U,$u) andalso ?OR(I,$I,$i) andalso ?OR(O,$O,$o) andalso
        ?OR(N,$N,$n) andalso ?OR(C,$C,$c) andalso
        (SP =:= $) orelse ?IS_SPACE(SP) orelse ?IS_NEWLINE(SP)) ->
    {Rest0, Pos0} = case remove_spaces(<<SP:8,Rest/binary>>, add_pos(Pos, 12)) of
        {<<"(",R0/binary>>, P0} ->
            {R0, add_pos(P0, 1)};
        {R0, P0} ->
            {R0, P0}
    end,
    {Rest1, Pos1, Exp} = expression(Rest0, Pos0, []),
    Include = add_line(#call{name = <<"require_once">>, args=[Exp]}, Pos),
    expression(Rest1, Pos1, add_op(Include, Parsed));
% AND
expression(<<A:8,N:8,D:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(A,$a,$A) andalso ?OR(N,$n,$N) andalso ?OR(D,$d,$D)
        andalso (not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_)) ->
    OpL = <<"and">>,
    expression(Rest, add_pos(Pos,3), add_op({OpL,precedence(OpL),Pos}, Parsed));
% XOR
expression(<<X:8,O:8,R:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(X,$x,$X) andalso ?OR(O,$o,$O) andalso ?OR(R,$r,$R)
        andalso (not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_)) ->
    OpL = <<"xor">>,
    expression(Rest, add_pos(Pos,3), add_op({OpL,precedence(OpL),Pos}, Parsed));
% OPERATOR 3 LETTERS
expression(<<Op:3/binary,Rest/binary>>, Pos, Parsed) when ?IS_OP3(Op) ->
    expression(Rest, add_pos(Pos,3), add_op({Op,precedence(Op),Pos}, Parsed));
% OR
expression(<<O:8,R:8,SP:8,Rest/binary>>, Pos, Parsed)
        when ?OR(O,$o,$O) andalso ?OR(R,$r,$R)
        andalso (not (?IS_ALPHA(SP) orelse ?IS_NUMBER(SP) orelse SP =:= $_)) ->
    OpL = <<"or">>,
    expression(Rest, add_pos(Pos,2), add_op({OpL,precedence(OpL),Pos}, Parsed));
% OPERATORS 2 LETTERS
expression(<<Op:2/binary,Rest/binary>>, Pos, Parsed) when ?IS_OP2(Op) ->
    expression(Rest, add_pos(Pos,2), add_op({Op,precedence(Op),Pos}, Parsed));
% OPERATORS 1 LETTER
expression(<<Op:1/binary,Rest/binary>>, Pos, Parsed) when ?IS_OP1(Op) ->
    expression(Rest, add_pos(Pos,1), add_op({Op,precedence(Op),Pos}, Parsed));
% CONSTANT / FUNCTION
expression(<<A:8,_/binary>> = Rest, {L,_,_}=Pos, [{op,[]}|_]=Parsed) when
        ?IS_ALPHA(A) orelse A =:= $_ ->
    {Rest0, {_,R,C}, [Constant]} = constant(Rest, Pos, []),
    expression(Rest0, {L,R,C}, add_op(Constant, Parsed));
expression(<<A:8,_/binary>> = Rest, {L,_,_}=Pos, [{op,Ops}|_]=Parsed) when
        ?IS_ALPHA(A) orelse A =:= $_ ->
    {Rest0, {_,R,C}, [Constant]} = constant(Rest, Pos, []),
    case lists:last(Ops) of
        #constant{} ->
            throw_error(eparse, Pos, {Constant#constant.name, <<"T_STRING">>});
        _ ->
            expression(Rest0, {L,R,C}, add_op(Constant, Parsed))
    end;
expression(<<A:8,_/binary>> = Rest, Pos, Parsed) when
        ?IS_ALPHA(A) orelse A =:= $_ ->
    {Rest0, Pos0, [Constant]} = constant(Rest, Pos, []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Constant, Parsed));
% FINAL -switch-
expression(<<":",_/binary>> = Rest, {switch_label,_,_}=Pos, [Exp]) ->
    {Rest, Pos, add_op('end', [Exp])};
% TERNARY OPERATOR
expression(<<"?", Rest/binary>>, Pos, Parsed) ->
    Op = <<"?">>,
    NewPos = add_pos(Pos, 1),
    QParsed = add_op({Op, precedence(Op), Pos}, Parsed),
    case expression(Rest, NewPos, []) of
        {<<":", Rest0/binary>>, Pos0, Parsed0} ->
            Op0 = <<":">>,
            {Rest1, Pos1, Parsed1} = expression(Rest0, add_pos(Pos0, 1), []),
            ToAdd = [Parsed0, [{Op0, precedence(Op0), Pos0}], Parsed1],
            XParsed = lists:foldl(fun add_op/2, QParsed, ToAdd),
            {Rest1, Pos1, add_op('end', XParsed)};
        {Rest0, _Pos0, _Parsed0} ->
            throw_error(eparse, Pos, Rest0)
    end;
expression(<<":",Rest/binary>>, Pos, Parsed) ->
    case lists:keyfind(<<"?">>, 1, Parsed) of
        {<<"?">>, _, _} ->
            Op = <<":">>,
            expression(Rest, add_pos(Pos, 1),
                       add_op({Op, precedence(Op), Pos}, Parsed));
        false ->
            {<<":", Rest/binary>>, Pos, add_op('end', Parsed)}
    end;
% FINAL -unclosed-
expression(Rest, {unclosed,_,_}=Pos, [Exp]) ->
    {Rest, Pos, add_op('end', [Exp])};
% PARSE ERROR
expression(<<>>, Pos, _Parsed) ->
    throw_error(eparse, Pos, <<>>).

exp_parens(Rest, {L, R, C} = Pos, Parsed) when not is_number(L) ->
    {Rest0, Pos0, Op} = expression(Rest, {1, R, C + 1}, []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Op, Parsed));
exp_parens(Rest, {L, R, C} = Pos, Parsed) ->
    {Rest0, Pos0, Op} = expression(Rest, {L + 1, R, C + 1}, []),
    expression(Rest0, copy_level(Pos, Pos0), add_op(Op, Parsed)).

-type associativity() :: no_assoc | left | right.
-spec precedence(binary()) -> {associativity(), pos_integer()} | false.

%% took from http://php.net/manual/en/language.operators.precedence.php

precedence(<<"clone">>) -> {no_assoc, 1};
precedence(<<"new">>) -> {no_assoc, 1};
precedence(<<"[">>) -> {left, 2}; %% array
precedence(<<"->">>) -> {left, 2}; %% object
precedence(<<"::">>) -> {left, 2}; %% class
precedence(<<"**">>) -> {right, 3}; %% arith
precedence(<<"++">>) -> {right, 4};
precedence(<<"--">>) -> {right, 4};
precedence(<<126>>) -> {right, 4}; %% ~ (types and increment/decrement)
precedence(<<"(int)">>) -> {right, 4};
precedence(<<"(float)">>) -> {right, 4};
precedence(<<"(string)">>) -> {right, 4};
precedence(<<"(array)">>) -> {right, 4};
precedence(<<"(object)">>) -> {right, 4};
precedence(<<"(bool)">>) -> {right, 4};
precedence(<<"(unset)">>) -> {right, 4};
precedence(<<"@">>) -> {right, 1};
precedence(<<"instanceof">>) -> {no_assoc, 5};
precedence(<<"!">>) -> {right, 6}; %% logic
precedence(<<"*">>) -> {left, 7};
precedence(<<"/">>) -> {left, 7};
precedence(<<"%">>) -> {left, 7};
precedence(<<"+">>) -> {left, 8};
precedence(<<"-">>) -> {left, 8};
precedence(<<".">>) -> {left, 8}; %% concat
precedence(<<"<<">>) -> {left, 9}; %% bit by bit
precedence(<<">>">>) -> {left, 9}; %% bit by bit
precedence(<<"<">>) -> {no_assoc, 10};
precedence(<<"<=">>) -> {no_assoc, 10};
precedence(<<">">>) -> {no_assoc, 10};
precedence(<<">=">>) -> {no_assoc, 10};
precedence(<<"==">>) -> {no_assoc, 11};
precedence(<<"!=">>) -> {no_assoc, 11};
precedence(<<"===">>) -> {no_assoc, 11};
precedence(<<"!==">>) -> {no_assoc, 11};
precedence(<<"<>">>) -> {no_assoc, 11};
precedence(<<"<=>">>) -> {no_assoc, 11};
precedence(<<"&">>) -> {left, 12}; %% bit by bit & references
precedence(<<"^">>) -> {left, 13}; %% bit by bit
precedence(<<"|">>) -> {left, 14}; %% bit by bit
precedence(<<"&&">>) -> {left, 15}; %% logic
precedence(<<"||">>) -> {left, 16}; %% logic
precedence(<<"??">>) -> {right, 17}; %% comparison
precedence(<<"?">>) -> {left, 18}; %% ternary
precedence(<<":">>) -> {left, 17}; %% ternary
precedence(<<"=">>) -> {right, 19}; %% assign
precedence(<<"+=">>) -> {right, 19};
precedence(<<"-=">>) -> {right, 19};
precedence(<<"*=">>) -> {right, 19};
precedence(<<"**=">>) -> {right, 19};
precedence(<<"/=">>) -> {right, 19};
precedence(<<".=">>) -> {right, 19};
precedence(<<"%=">>) -> {right, 19};
precedence(<<"&=">>) -> {right, 19};
precedence(<<"|=">>) -> {right, 19};
precedence(<<"^=">>) -> {right, 19};
precedence(<<"<<=">>) -> {right, 19};
precedence(<<">>=">>) -> {right, 19};
precedence(<<"and">>) -> {left, 20};
precedence(<<"xor">>) -> {left, 21};
precedence(<<"or">>) -> {left, 22};
precedence(_) -> false.

operator(<<":">> = Op,Left,Right) ->
    #operation{type=Op, expression_left=Left, expression_right=Right};
operator(<<"?">> = Op,Left,Right) ->
    #operation{type=Op, expression_left=Left, expression_right=Right};
operator(<<"and">>,Left,Right) -> operator('and',Left,Right);
operator(<<"or">>,Left,Right) -> operator('or',Left,Right);
operator(<<"xor">>,Left,Right) -> operator('xor',Left,Right);
operator(<<"&&">>,Left,Right) -> operator('and',Left,Right);
operator(<<"||">>,Left,Right) -> operator('or',Left,Right);
operator(<<"^^">>,Left,Right) -> operator('xor',Left,Right);
operator(<<"<=">>,Left,Right) -> operator(<<"=<">>,Left,Right);
operator(Op,R1,R2) when is_boolean(R1) andalso is_boolean(R2) ->
    case Op of
        'and' -> R1 and R2;
        'or' -> R1 or R2;
        'xor' -> R1 xor R2;
        _ -> #operation{type=Op, expression_left=R1, expression_right=R2}
    end;
operator(<<"/">>,R1,R2) when (is_record(R1, int) orelse is_record(R1, float))
                     andalso (is_record(R2, int) orelse is_record(R2, float)) ->
    N2 = element(2, R2),
    case N2 == 0 of
        true ->
            #operation{
                type = <<"/">>,
                expression_left=R1,
                expression_right=R2};
        false ->
            N1 = element(2, R1),
            Res = N1 / N2,
            if
                is_integer(Res) -> #int{int=Res};
                is_float(Res) -> #float{float=Res}
            end
    end;
operator(Op,R1,R2) when (is_record(R1, int) orelse is_record(R1, float))
                andalso (is_record(R2, int) orelse is_record(R2, float)) ->
    N1 = element(2, R1),
    N2 = element(2, R2),
    Res = case Op of
        <<"+">> -> N1+N2;
        <<"-">> -> N1-N2;
        <<"*">> -> N1*N2;
        <<"%">> -> N1 rem N2;
        <<">">> -> N1 > N2;
        <<"<">> -> N1 < N2;
        <<"==">> -> N1 == N2;
        <<"===">> -> N1 =:= N2;
        <<"=<">> -> N1 =< N2;
        <<">=">> -> N1 >= N2;
        <<"^">> -> N1 bxor N2;
        <<"&">> -> N1 band N2;
        <<"|">> -> N1 bor N2;
        <<"<<">> -> N1 bsl N2;
        <<">>">> -> N1 bsr N2;
        'xor' -> ephp_data:to_bool(N1) xor ephp_data:to_bool(N2);
        'or' -> ephp_data:to_bool(N1) or ephp_data:to_bool(N2);
        'and' -> ephp_data:to_bool(N1) and ephp_data:to_bool(N2)
    end,
    if
        is_integer(Res) -> #int{int=Res};
        is_float(Res) -> #float{float=Res};
        is_boolean(Res) -> Res
    end;
operator(<<".">>,#text{text=T1},#text{text=T2}) ->
    #text{text = <<T1/binary,T2/binary>>};
operator(<<".">>,Left,Right) ->
    ProcessedLeft = concat(Left),
    ProcessedRight = concat(Right),
    #concat{texts=ProcessedLeft ++ ProcessedRight};
operator(Op,Left,Right) ->
    #operation{type=Op, expression_left=Left, expression_right=Right}.

concat(#concat{texts=T}) -> T;
concat(T) -> [T].

solve(Expression) ->
    Postfix = shunting_yard(parse_negative(Expression), [], []),
    case gen_op(Postfix, []) of
        [Operation] ->
            Operation;
        [{UnExpected, _, Pos}|_] ->
            throw_error(eparse, Pos, {unexpected, UnExpected})
    end.

gen_op([], Stack) ->
    Stack;
gen_op([{<<"=">>,{_,_},Pos}|Rest], [B,{operation_not, A, Line}|Stack]) ->
    Assign = add_line(#assign{variable=A, expression=B}, Pos),
    gen_op(Rest, [{operation_not, Assign, Line}|Stack]);
gen_op([{<<"=">>,{_,_},Pos}|Rest], [B,A|Stack]) ->
    Assign = add_line(#assign{variable=A, expression=B}, Pos),
    gen_op(Rest, [Assign|Stack]);
gen_op([{<<O:1/binary,"=">>,{_,_},Pos}|Rest], [B,A|Stack])
        when ?IS_OP1_ARITH(O) ->
    Op = add_line(operator(O, A, B), Pos),
    Assign = add_line(#assign{variable=A, expression=Op}, Pos),
    gen_op(Rest, [Assign|Stack]);
gen_op([#variable{} = V, {<<"&">>, _, Pos}|Rest], []) ->
    gen_op(Rest, [add_line(#ref{var = V}, Pos)]);
gen_op([#variable{} = V, {<<"&">>, _, Pos}, {<<"=">>, _, _} = A|Rest], Stack) ->
    gen_op([A|Rest], [add_line(#ref{var=V}, Pos)|Stack]);
gen_op([#call{} = C, {<<"&">>, _, _Pos}|Rest], []) ->
    gen_op(Rest, [C]);
gen_op([#call{} = C, {<<"&">>, _, _Pos}, {<<"=">>, _, _} = A|Rest], Stack) ->
    gen_op([A|Rest], [C|Stack]);
gen_op([{<<"@">>,{right,_},{_,_,_}}|Rest], [A|Stack]) ->
    gen_op(Rest, [{silent, A}|Stack]);
gen_op([{<<126>>,{_,_},{_,R,C}}|Rest], [A|Stack]) ->
    gen_op(Rest, [{operation_bnot, A, {{line,R},{column,C}}}|Stack]);
gen_op([{<<"!">>,{_,_},{_,R,C}}|Rest], [A|Stack]) ->
    gen_op(Rest, [{operation_not, A, {{line,R},{column,C}}}|Stack]);
gen_op([#constant{name = <<"break">>}, #int{int=I}], []) ->
    [{break, I}];
gen_op([#constant{name = <<"continue">>}, #int{int=I}], []) ->
    [{continue, I}];
gen_op([{<<"->">>,{_,_},Pos}|Rest], [B,#variable{idx=Idx}=A|Stack]) ->
    Object = case B of
        #int{int = I} -> add_line({object, ephp_data:to_bin(I)}, Pos);
        #float{float = F} -> add_line({object, ephp_data:to_bin(F)}, Pos);
        #constant{name = Name} -> add_line({object, Name}, Pos);
        #variable{} -> add_line({object, B}, Pos);
        #call{} -> add_line({object, B}, Pos);
        #text_to_process{} -> add_line({object, B}, Pos);
        _ -> throw_error(eparse, Pos,
                         {<<"`\"identifier (T_STRING)\"' or "
                            "`\"variable (T_VARIABLE)\"' or "
                            "`'{'' or `'$''">>})
    end,
    gen_op(Rest, [A#variable{idx = Idx ++ [Object]}|Stack]);
gen_op([{<<"++">>, {_,_}, Pos}|Rest], [V|Stack]) ->
    gen_op(Rest, [{post_incr, V, Pos}|Stack]);
gen_op([{<<"--">>, {_,_}, Pos}|Rest], [V|Stack]) ->
    gen_op(Rest, [{post_decr, V, Pos}|Stack]);
gen_op([{<<"::">>,{_,_},_Pos}|Rest], [#constant{} = A,B|Stack]) ->
    gen_op(Rest, [A#constant{type = class, class = B}|Stack]);
gen_op([{<<"(int)">>,{_,_},_Pos}|Rest], [#int{}=I|Stack]) ->
    gen_op(Rest, [I|Stack]);
gen_op([{<<"(int)">>,{_,_},Pos}|Rest], [#float{float=F}|Stack]) ->
    gen_op(Rest, [add_line(#int{int=ephp_data:flooring(F)}, Pos)|Stack]);
gen_op([{<<"(int)">>,{_,_},Pos}|Rest], [#text{text=T}|Stack]) ->
    gen_op(Rest, [add_line(#int{int=ephp_data:bin_to_number(T)}, Pos)|Stack]);
gen_op([{<<"(int)">>,{_,_},Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#cast{type=int, content=A}, Pos)|Stack]);
gen_op([{<<"(float)">>,{_,_},Pos}|Rest], [#int{int=I}|Stack]) ->
    gen_op(Rest, [add_line(#float{float=erlang:float(I)}, Pos)|Stack]);
gen_op([{<<"(float)">>,{_,_},_Pos}|Rest], [#float{}=F|Stack]) ->
    gen_op(Rest, [F|Stack]);
gen_op([{<<"(float)">>,{_,_},Pos}|Rest], [#text{text=T}|Stack]) ->
    Float = erlang:float(ephp_data:bin_to_number(T)),
    gen_op(Rest, [add_line(#int{int=Float}, Pos)|Stack]);
gen_op([{<<"(float)">>,{_,_},Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#cast{type=float, content=A}, Pos)|Stack]);
gen_op([{<<"(string)">>,{_,_},Pos}|Rest], [#int{int=I}|Stack]) ->
    gen_op(Rest, [add_line(#text{text=ephp_data:to_bin(I)}, Pos)|Stack]);
gen_op([{<<"(string)">>,{_,_},_Pos}|Rest], [#text{}=T|Stack]) ->
    gen_op(Rest, [T|Stack]);
gen_op([{<<"(string)">>,{_,_},Pos}|Rest], [#float{float=F}|Stack]) ->
    gen_op(Rest, [add_line(#text{text=ephp_data:to_bin(F)}, Pos)|Stack]);
gen_op([{<<"(string)">>,{_,_},Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#cast{type=string, content=A}, Pos)|Stack]);
gen_op([{<<"(bool)">>,{_,_},_Pos}|Rest], [#int{int=I}|Stack]) ->
    gen_op(Rest, [ephp_data:to_bool(I)|Stack]);
gen_op([{<<"(bool)">>,{_,_},_Pos}|Rest], [#text{text=T}|Stack]) ->
    gen_op(Rest, [ephp_data:to_bool(T)|Stack]);
gen_op([{<<"(bool)">>,{_,_},_Pos}|Rest], [#float{float=F}|Stack]) ->
    gen_op(Rest, [ephp_data:to_bool(F)|Stack]);
gen_op([{<<"(bool)">>,{_,_},Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#cast{type=bool, content=A}, Pos)|Stack]);
gen_op([{<<"(array)">>,{_,_},Pos}|Rest], [#int{line=DPos}=D|Stack]) ->
    gen_op(Rest, [add_to_array(#array{line=DPos}, Pos, D)|Stack]);
gen_op([{<<"(array)">>,{_,_},Pos}|Rest], [#text{line=DPos}=D|Stack]) ->
    gen_op(Rest, [add_to_array(#array{line=DPos}, Pos, D)|Stack]);
gen_op([{<<"(array)">>,{_,_},Pos}|Rest], [#float{line=DPos}=D|Stack]) ->
    gen_op(Rest, [add_to_array(#array{line=DPos}, Pos, D)|Stack]);
gen_op([{<<"(array)">>,{_,_},Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#cast{type=array, content=A}, Pos)|Stack]);
gen_op([{<<"(object)">>,{_,_},Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#cast{type=object, content=A}, Pos)|Stack]);
gen_op([{<<"(unset)">>,{_,_},_Pos}|Rest], [_|Stack]) ->
    gen_op(Rest, [undefined|Stack]);
gen_op([{<<"clone">>, {_, _}, Pos}|Rest], [A|Stack]) ->
    gen_op(Rest, [add_line(#clone{var = A}, Pos)|Stack]);
% TODO add the rest of casting operators
gen_op([{<<"?">>,{_,_},Pos}|Rest],
       [#operation{type = <<":">>}=OpElse,Cond|Stack]) ->
    #operation{
        expression_left = TrueBlock,
        expression_right = FalseBlock
    } = OpElse,
    IfBlock = #if_block{
        conditions = Cond,
        true_block = TrueBlock,
        false_block = FalseBlock,
        line = Pos
    },
    gen_op(Rest, [IfBlock|Stack]);
gen_op([{<<"?">>,{_,_},Pos}|_Rest], _Stack) ->
    throw_error(eparse, Pos, <<>>);
gen_op([{Op,{_,_},Pos}|Rest], [B,A|Stack]) ->
    gen_op(Rest, [add_line(operator(Op,A,B),Pos)|Stack]);
gen_op([A|Rest], Stack) ->
    gen_op(Rest, [A|Stack]).

add_to_array(#array{elements=E}=Array, Pos, Element) ->
    Array#array{elements=E ++ [
        add_line(#array_element{element=Element}, Pos)
    ]}.

parse_negative(Elements) ->
    parse_negative(lists:reverse(Elements), []).

parse_negative([#int{}=I,{<<"-">>,{_,_},_},{_,{_,_},_}=Op|Rest], Stack) ->
    parse_negative([I#int{int=-I#int.int},Op|Rest], Stack);
parse_negative([#float{}=F,{<<"-">>,{_,_},_},{_,{_,_},_}=Op|Rest], Stack) ->
    parse_negative([F#float{float=-F#float.float},Op|Rest], Stack);
parse_negative([A,{<<"-">>,{_,_},_},{_,{_,_},_}=Op|Rest], Stack) ->
    parse_negative([{operation_minus, A, undefined},Op|Rest], Stack);
parse_negative([#int{}=I,{<<"-">>,{_,_},_}], Stack) ->
    [I#int{int=-I#int.int}|Stack];
parse_negative([#float{}=F,{<<"-">>,{_,_},_}], Stack) ->
    [F#float{float=-F#float.float}|Stack];
parse_negative([A,{<<"-">>,{_,_},_}], Stack) ->
    [{operation_minus, A, undefined}|Stack];
parse_negative([A|Rest], Stack) ->
    parse_negative(Rest, [A|Stack]);
parse_negative([], Stack) ->
    Stack.

shunting_yard([], [], Postfix) ->
    Postfix;
shunting_yard([], OpS, Postfix) ->
    Postfix ++ OpS;
shunting_yard([{_,{_,_},_}=Op|Rest], [], Postfix) ->
    shunting_yard(Rest, [Op], Postfix);
shunting_yard([{_,{left,P1},_}=Op|Rest], [{_,{_,P2},_}=Op1|OpS], Postfix)
        when P1 > P2 ->
    shunting_yard(Rest, [Op|OpS], Postfix ++ [Op1]);
shunting_yard([{_,{_,P1},_}=Op|Rest], [{_,{_,P2},_}=Op1|OpS], Postfix)
        when P1 >= P2 ->
    shunting_yard(Rest, [Op|OpS], Postfix ++ [Op1]);
shunting_yard([{_,{left,P1},_}=Op|Rest], [{_,{_,P2},_}|_]=OpS, Postfix)
        when P1 =< P2 ->
    shunting_yard(Rest, [Op|OpS], Postfix);
shunting_yard([{_,{_,P1},_}=Op|Rest], [{_,{_,P2},_}|_]=OpS, Postfix)
        when P1 < P2 ->
    shunting_yard(Rest, [Op|OpS], Postfix);
shunting_yard([A|Rest], OpS, Postfix) ->
    shunting_yard(Rest, OpS, Postfix ++ [A]).
