%% Author: Manuel Rubio <manuel@altenwald.com>

-define(PHP_INI_FILE, <<"php.ini">>).

-define(PHP_MAJOR_VERSION, "5").
-define(PHP_MINOR_VERSION, "6").
-define(PHP_RELEASE_VERSION, "0").
-define(PHP_EXTRA_VERSION, "erlang").
-define(PHP_VERSION, <<?PHP_MAJOR_VERSION, ".",
                       ?PHP_MINOR_VERSION, ".",
                       ?PHP_RELEASE_VERSION, "-",
                       ?PHP_EXTRA_VERSION>>).
-define(PHP_VERSION_ID, 50600).

%% 256 bits
-define(PHP_INT_MAX, 340282366920938463463374607431768211456).
-define(PHP_INT_MIN, -340282366920938463463374607431768211455).
-define(PHP_INT_SIZE, 32).

-define(PATH_SEP, <<":">>).

-define(FUNC_ANON_NAME, <<"{closure}">>).

-define(IS_ARRAY(A), is_record(A, ephp_array)).
-define(IS_OBJECT(O), is_record(O, obj_ref)).
-define(IS_FUNCTION(F), is_record(F, function)).
-define(IS_MEM(M), is_record(M, mem_ref)).
-define(IS_CLASS(C), is_record(C, class)).
-define(IS_RESOURCE(R), is_record(R, resource)).

-define(PHP_INF, infinity).
-define(PHP_NAN, nan).

% built-in modules
-define(MODULES, [
    ephp_lib_date,
    ephp_lib_vars,
    ephp_lib_math,
    ephp_lib_misc,
    ephp_lib_ob,
    ephp_lib_control,
    ephp_lib_array,
    ephp_lib_string,
    ephp_lib_file,
    ephp_lib_func,
    ephp_lib_info,
    ephp_lib_class,
    ephp_lib_error,
    ephp_lib_pcre,
    ephp_lib_spl,
    ephp_lib_exec
]).

-define(E_ERROR, 1).
-define(E_WARNING, 2).
-define(E_PARSE, 4).
-define(E_NOTICE, 8).
-define(E_CORE_ERROR, 16).
-define(E_CORE_WARNING, 32).
-define(E_COMPILE_ERROR, 64).
-define(E_COMPILE_WARNING, 128).
-define(E_USER_ERROR, 256).
-define(E_USER_WARNING, 512).
-define(E_USER_NOTICE, 1024).
-define(E_STRICT, 2048).
-define(E_RECOVERABLE_ERROR, 4096).
-define(E_DEPRECATED, 8192).
-define(E_USER_DEPRECATED, 16384).
-define(E_ALL, 32767).
-define(E_HANDLE_ERRORS, 2#011111100001010).
-define(E_EXIT_ON_FALSE, 2#001000100000000).
-define(E_USER, 2#000011100000000).
-define(DEBUG_BACKTRACE_PROVIDE_OBJECT, 1).
-define(DEBUG_BACKTRACE_IGNORE_ARGS, 2).

-define(PHP_DEFAULT_TIMEZONE, <<"UTC">>).

-define(SORT_REGULAR, 0).
-define(SORT_NUMERIC, 1).
-define(SORT_STRING, 2).
-define(SORT_LOCALE_STRING, 5).
-define(SORT_FLAG_CASE, 8).

-type error_level() :: pos_integer().

-type date() :: {Year :: integer(), Month :: integer(), Day :: integer()}.

-type file_name() :: binary().

-record(ephp_array, {
    size = 0 :: non_neg_integer(),
    values = [] :: [any()],
    last_num_index = 0 :: non_neg_integer(),
    cursor = 1 :: pos_integer() | false
}).

-type ephp_array() :: #ephp_array{}.

-type mixed() ::
    integer() | float() | binary() | boolean() | ephp_array() |
    obj_ref() | mem_ref() | var_ref() | undefined.

-type var_value() :: {variable(), mixed()}.

-type context() :: reference().

-type statement() :: tuple() | atom().
-type statements() :: [statement()].

-type expression() :: operation().

-type reason() :: atom() | string().

-type line() :: {{line, non_neg_integer()}, {column, non_neg_integer()}} |
                undefined.

% main statements

-record(eval, {
    statements :: statements(),
    line :: line()
}).

-record(print, {
    expression :: expression(),
    line :: line()
}).

-record(print_text, {
    text :: binary(),
    line :: line()
}).

-type main_statement() :: #eval{} | #print{} | #print_text{}.

% blocks

-record(if_block, {
    conditions :: condition(),
    true_block :: statements(),
    false_block :: statements(),
    line :: line()
}).

-record(for, {
    init :: expression(),
    conditions :: condition(),
    update :: expression(),
    loop_block :: statements(),
    line :: line()
}).

-record(while, {
    type :: (pre | post),
    conditions :: condition(),
    loop_block :: statements(),
    line :: line()
}).

-record(foreach, {
    kiter :: variable(),
    iter :: variable(),
    elements :: variable(),
    loop_block :: statements(),
    line :: line()
}).

-record(switch_case, {
    label :: default | mixed(),
    code_block :: statements(),
    line :: line()
}).

-type switch_case() :: #switch_case{}.
-type switch_cases() :: [switch_case()].

-record(switch, {
    condition :: condition(),
    cases :: switch_cases(),
    line :: line()
}).

-type if_block() :: #if_block{}.

% data types and operations

-type ternary() :: if_block().

-record(operation, {
    type :: binary() | atom(),
    expression_left :: variable(),
    expression_right :: expression(),
    line :: line()
}).

-type operation_not() :: {operation_not, condition()}.

-record(cast, {
    type :: int | float | string | array | object | bool,
    content :: mixed(),
    line :: line()
}).

-type cast() :: #cast{}.

-type condition() :: expression() | operation().
-type conditions() :: [condition()].

-type operation() :: #operation{}.

-type arith_mono() :: pre_incr() | pre_decr() | post_incr() | post_decr().

-type array_index() :: arith_mono() | ternary() | binary() | operation().

-type post_decr() :: {post_decr, variable(), line()}.
-type pre_decr() :: {pre_decr, variable(), line()}.
-type post_incr() :: {post_incr, variable(), line()}.
-type pre_incr() :: {pre_incr, variable(), line()}.

-record(return, {
    value :: mixed(),
    line :: line()
}).

-type return() :: #return{}.

-record(throw, {
    value :: mixed(),
    line :: line()
}).

-type throw() :: #throw{}.

-record(global, {
    vars :: [variable()],
    line :: line()
}).

-type global() :: #global{}.

-record(int, {
    int :: integer(),
    line :: line()
}).

-record(float, {
    float :: float(),
    line :: line()
}).

-record(text, {
    text :: binary(),
    line :: line()
}).

-record(text_to_process, {
    text :: [expression() | variable() | binary()],
    line :: line()
}).

-record(command, {
    text :: [expression() | variable() | binary()],
    line :: line()
}).

-type constant_types() :: normal | class | define.

-record(constant, {
    name :: binary(),
    type = normal :: constant_types(),
    value :: expression(),
    class :: class_name() | undefined,
    line :: line()
}).

-type constant() :: #constant{}.

-type object_index() :: {object, binary(), line()}.
-type class_index() :: {class, binary(), line()}.

-type variable_types() :: normal | array | object | class | static.
-type data_type() :: binary() | undefined.

-record(variable, {
    type = normal :: variable_types(),
    class :: class_name() | undefined,
    name :: binary(),
    idx = [] :: [array_index() | object_index() | class_index()],
    default_value = undefined :: mixed(),
    data_type :: data_type(), %% <<"Exception">> for example
    line :: line()
}).

-type variable() :: #variable{}.

-record(array_element, {
    idx = auto :: auto | expression(),
    element :: expression(),
    line :: line()
}).

-type array_element() :: #array_element{}.

-record(array, {
    elements = [] :: [array_element()],
    line :: line()
}).

-type php_array() :: #array{}.

% statements

-record(assign, {
    variable :: variable(),
    expression :: expression(),
    line :: line()
}).

-type call_types() :: normal | class | object.
-type class_name() :: binary().

-record(call, {
    type = normal :: call_types(),
    class :: undefined | class_name(),
    name :: binary() | obj_ref() | ephp_array(),
    args = [] :: [expression()],
    line :: line()
}).

-type function_name() :: binary().

-record(function, {
    name :: function_name() | undefined,
    args = [] :: [variable()],
    use = [] :: [variable()],
    code :: statements(),
    return_ref = false :: boolean(),
    line :: line()
}).

-type callable() :: function_name() | ephp_array().

-record(stack_trace, {
    function :: binary(),
    line :: integer() | undefined,
    file :: binary() | undefined,
    class :: binary() | undefined,
    object :: obj_ref() | undefined,
    type :: binary() | undefined, %% ::, -> or undefined
    args :: [mixed()]
}).

-type stack_trace() :: #stack_trace{}.

-record(ref, {
    var :: variable(),
    line :: line()
}).

-record(concat, {
    texts :: [any()],
    line :: line()
}).

% variable values (ephp_vars)

-record(var_value, {
    content :: any()
}).

-record(var_ref, {
    pid :: context() | undefined,
    ref :: #variable{} | global | undefined
}).

-type var_ref() :: #var_ref{}.

-record(obj_ref, {
    pid :: ephp:objects_id(),
    ref :: object_id()
}).

-type obj_ref() :: #obj_ref{}.

-type object_id() :: pos_integer().

-record(mem_ref, {
    mem_id :: mem_id()
}).

-type mem_ref() :: #mem_ref{}.

-type mem_id() :: pos_integer().

-record(resource, {
    id :: pos_integer(),
    pid :: any(),
    module :: module()
}).

-type resource() :: #resource{}.

% classes

-record(class_const, {
    name :: binary(),
    value :: any(),
    line :: line()
}).

-type class_const() :: #class_const{}.

-type access_types() :: public | protected | private.

-record(class_attr, {
    name :: binary(),
    access = public :: access_types(),
    type = normal :: normal | static,
    init_value = undefined :: mixed(),
    final = false :: boolean(),
    class_name :: class_name(),
    line :: line()
}).

-type class_attr() :: #class_attr{}.

-record(class_method, {
    name :: binary(),
    code_type = php :: php | builtin,
    args = [] :: [variable()],
    access = public :: access_types(),
    type = normal :: normal | static | abstract,
    code :: [statement()] | {module(), Func :: atom()},
    builtin :: {Module :: atom(), Func :: atom()},
    pack_args = false :: boolean(),
    validation_args :: ephp_func:validation_args(),
    static = [] :: static(),
    final = false :: boolean(),
    class_name :: class_name(),
    line :: line()
}).

-type class_method() :: #class_method{}.
-type class_type() :: normal | static | abstract | interface.

-record(class, {
    name :: class_name(),
    type = normal :: class_type(),
    final = false :: boolean(),
    parents = [] :: [class_name()],
    extends :: undefined | class_name(),
    implements = [] :: [class_name()],
    constants = [] :: [class_const()],
    attrs = [] :: [class_attr()],
    methods = [] :: [class_method()],
    file :: binary(),
    line :: line(),
    static_context :: context()
}).

-type class() :: #class{}.

-record(instance, {
    name :: class_name(),
    args :: [variable()],
    line :: line()
}).

-type instance() :: #instance{}.

-type static_arg_name() :: binary().
-type static() :: [{static_arg_name(), mixed()}].

-record(reg_func, {
    name :: binary(),
    args :: [variable()],
    type :: builtin | php,
    file :: binary(),
    code = [] :: [statement()],
    builtin :: {Module :: atom(), Func :: atom()},
    pack_args = false :: boolean(),
    validation_args :: ephp_func:validation_args(),
    static = [] :: static()
}).

-record(ephp_object, {
    id :: pos_integer(),
    class :: class(),
    instance :: instance(),
    context :: context(),
    objects :: ephp:objects_id(),   %% TODO: check if objects is really needed
    links = 1 :: pos_integer()
}).

-type ephp_object() :: #ephp_object{}.

-record(clone, {
    var :: variable(),
    line :: line()
}).

-type clone() :: #clone{}.

-record(try_catch, {
    code_block :: statements(),
    catches = [] :: [catch_block()],
    finally = [] :: statements(),
    line :: line()
}).

-type try_catch() :: #try_catch{}.

-record(catch_block, {
    exception :: variable(),
    code_block :: statements(),
    line :: line()
}).

-type catch_block() :: #catch_block{}.

