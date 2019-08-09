-module(ephp_lib_func).
-author('manuel@altenwald.com').
-compile([warnings_as_errors]).

-behaviour(ephp_func).

-export([
    init_func/0,
    init_config/0,
    init_const/0,
    register_shutdown_function/3,
    get_defined_functions/2,
    function_exists/3,
    func_num_args/2,
    call_user_func/3,
    call_user_func_array/4,
    create_function/4
]).

-include("ephp.hrl").

-spec init_func() -> ephp_func:php_function_results().

init_func() -> [
    {register_shutdown_function, [pack_args]},
    get_defined_functions,
    function_exists,
    func_num_args,
    {call_user_func, [pack_args]},
    {call_user_func_array, [callable, array]},
    {create_function, [{args, [string, string]}]}
].

-spec init_config() -> ephp_func:php_config_results().

init_config() -> [].

-spec init_const() -> ephp_func:php_const_results().

init_const() -> [].

-spec register_shutdown_function(context(), line(), [var_value()]) -> ok.

register_shutdown_function(Context, _Line, [{_,Callback}|_RawArgs]) ->
    %% TODO: add params to call the functions.
    ephp_context:register_shutdown_func(Context, Callback),
    ok.

-spec func_num_args(context(), line()) -> non_neg_integer().

func_num_args(Context, _Line) ->
    ephp_context:get_active_function_arity(Context).

-spec get_defined_functions(context(), line()) -> ephp_array().

get_defined_functions(Context, _Line) ->
    Append = fun({Func,Type}, {I,Dict}) ->
        NewTypeDict = case ephp_array:find(Type, Dict) of
            {ok,TypeDict} ->
                ephp_array:store(I, Func, TypeDict)
        end,
        {I+1,ephp_array:store(Type, NewTypeDict, Dict)}
    end,
    BaseDict = ephp_array:store(<<"user">>, ephp_array:new(),
        ephp_array:store(<<"internal">>, ephp_array:new(), ephp_array:new())),
    Functions = ephp_context:get_functions(Context),
    {_,FuncList} = lists:foldl(Append, {0,BaseDict}, Functions),
    FuncList.

-spec function_exists(context(), line(), FuncName :: var_value()) -> boolean().

function_exists(Context, _Line, {_,FuncName}) ->
    ephp_context:get_function(Context, FuncName) =/= error.

-spec call_user_func_array(context(), line(), var_value(), var_value()) -> mixed().

call_user_func_array(Context, _Line, {_, FuncName}, {_, Args}) ->
    call(Context, FuncName, ephp_array:values(Args)).

-spec call_user_func(context(), line(), [var_value()]) -> mixed().

call_user_func(Context, _Line, [{_, FuncName}|Args]) when is_binary(FuncName)
                                                   orelse ?IS_ARRAY(FuncName)
                                                   orelse ?IS_OBJECT(FuncName) ->
    call(Context, FuncName, [ Arg || {_, Arg} <- Args ]);
call_user_func(Context, Line, _Args) ->
    File = ephp_context:get_active_file(Context),
    Data = {<<"call_user_func">>, 1, <<"a valid callback">>, <<"no array or string">>},
    Error = {error, ewrongarg, Line, File, ?E_WARNING, Data},
    ephp_error:handle_error(Context, Error),
    false.

-spec create_function(context(), line(), Args :: var_value(),
                      Code :: var_value()) -> #function{}.

create_function(_Context, {{line, Line}, _}, {_, Args}, {_, Code}) ->
    Pos = {code, Line, 1},
    {_, _, A} = ephp_parser_func:funct_args(<<Args/binary, ")">>, Pos, []),
    {_, _, C} = ephp_parser:code(Code, Pos, []),
    ephp_parser:add_line(#function{args = A, code = C}, Pos).


call(Context, FuncName, Args) when is_binary(FuncName) andalso is_list(Args) ->
    case binary:split(FuncName, <<"::">>) of
        [ClassName, StaticMethod] ->
            Call = #call{name = StaticMethod, class = ClassName, type = class},
            ephp_context:call_function(Context, Call);
        [FuncName] ->
            Call = #call{name = FuncName, args = Args},
            ephp_context:call_function(Context, Call)
    end;
call(Context, Callable, Args) when ?IS_ARRAY(Callable) andalso is_list(Args) ->
    case ephp_array:to_list(Callable) of
        [{_,Object}, {_,Method}] when ?IS_OBJECT(Object) andalso
                                      is_binary(Method) ->
            Call = #call{name = Method, type = object, args = Args},
            ephp_context:call_method(Context, Object, Call);
        [{_,Class}, {_,Method}] when is_binary(Class) andalso is_binary(Method) ->
            case binary:split(Method, <<"::">>) of
                [Method] ->
                    Call = #call{name = Method, class = Class, type = class},
                    ephp_context:call_function(Context, Call);
                [<<"parent">>, ParentMethod] ->
                    %% TODO: when parent isn't defined
                    ParentName = ephp_class:get_parent(Context, Class),
                    Call = #call{name = ParentMethod, class = ParentName,
                                 type = class},
                    ephp_context:call_function(Context, Call)
            end
    end;
call(Context, Object, Args) when ?IS_OBJECT(Object) andalso is_list(Args) ->
    %% TODO: error when __invoke is not defined
    Call = #call{name = <<"__invoke">>, type = object, args = Args},
    ephp_context:call_method(Context, Object, Call).
