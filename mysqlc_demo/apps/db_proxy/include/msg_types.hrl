-ifndef(_msg_types_included).
-define(_msg_types_included, yeah).

%% struct 'Message'

-record('Message', {'id' :: integer(),
                    'text' :: string() | binary()}).
-type 'Message'() :: #'Message'{}.

%% struct 'QueryReq'

-record('QueryReq', {'pool_id' :: integer(),
                     'sql' :: string() | binary()}).
-type 'QueryReq'() :: #'QueryReq'{}.

%% struct 'QueryReply'

-record('QueryReply', {'code' :: integer(),
                       'msg' :: string() | binary(),
                       'result' :: string() | binary()}).
-type 'QueryReply'() :: #'QueryReply'{}.

%% struct 'SelectReq'

-record('SelectReq', {'pool_id' :: integer(),
                      'sql' :: string() | binary()}).
-type 'SelectReq'() :: #'SelectReq'{}.

%% struct 'SelectReply'

-record('SelectReply', {'code' :: integer(),
                        'msg' :: string() | binary(),
                        'result' :: string() | binary()}).
-type 'SelectReply'() :: #'SelectReply'{}.

%% struct 'DatabaseConfigReq'

-record('DatabaseConfigReq', {'pool_id' :: integer()}).
-type 'DatabaseConfigReq'() :: #'DatabaseConfigReq'{}.

%% struct 'DatabaseConfigReply'

-record('DatabaseConfigReply', {'code' :: integer(),
                                'host' :: string() | binary(),
                                'port' :: integer(),
                                'user' :: string() | binary(),
                                'password' :: string() | binary(),
                                'database' :: string() | binary()}).
-type 'DatabaseConfigReply'() :: #'DatabaseConfigReply'{}.

-endif.
