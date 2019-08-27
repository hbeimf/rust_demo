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

-endif.
