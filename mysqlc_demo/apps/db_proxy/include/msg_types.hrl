-ifndef(_msg_types_included).
-define(_msg_types_included, yeah).

%% struct 'Message'

-record('Message', {'id' :: integer(),
                    'text' :: string() | binary()}).
-type 'Message'() :: #'Message'{}.

%% struct 'UserInfo'

-record('UserInfo', {'uid' :: integer(),
                     'name' :: string() | binary()}).
-type 'UserInfo'() :: #'UserInfo'{}.

%% struct 'ServerReply'

-record('ServerReply', {'code' :: integer(),
                        'text' :: string() | binary()}).
-type 'ServerReply'() :: #'ServerReply'{}.

%% struct 'QueryReq'

-record('QueryReq', {'pool_id' :: integer(),
                     'sql' :: string() | binary()}).
-type 'QueryReq'() :: #'QueryReq'{}.

%% struct 'QueryReply'

-record('QueryReply', {'code' :: integer(),
                       'msg' :: string() | binary(),
                       'result' :: string() | binary()}).
-type 'QueryReply'() :: #'QueryReply'{}.

%% struct 'SelectCiSessionsReq'

-record('SelectCiSessionsReq', {'pool_id' :: integer(),
                                'page' :: integer(),
                                'page_size' :: integer()}).
-type 'SelectCiSessionsReq'() :: #'SelectCiSessionsReq'{}.

%% struct 'SelectCiSessionsReply'

-record('SelectCiSessionsReply', {'code' :: integer(),
                                  'msg' :: string() | binary(),
                                  'rows' :: list()}).
-type 'SelectCiSessionsReply'() :: #'SelectCiSessionsReply'{}.

%% struct 'RowCiSessions'

-record('RowCiSessions', {'id' :: integer(),
                          'name' :: string() | binary()}).
-type 'RowCiSessions'() :: #'RowCiSessions'{}.

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
