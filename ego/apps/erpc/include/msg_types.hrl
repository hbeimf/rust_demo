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

-endif.
