defmodule Gwc.GwcAction do
    require Elog
    require Eglib

    # action(Msg) ->
    #     {Action, Package} = glib_pb:decode_Msg(Msg),
      
    #     % #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
    #     % action(Cmd, ReqPackage, From),
    #     action(Action, Package),
    #     ok.

    def action(msg) do
        {action, package} = :glib_pb.decode_Msg(msg)
        action(action, package)
        :ok
    end

    def action(Eglib.cmd_REGISTER, package) do
        Elog.print({Eglib.cmd_REGISTER, package})
        :ok
    end
    # action(?CMD_CALL_FUN, Package) -> 
    #     #request{from = From, req_cmd = _Cmd, req_data = {Mod, F, Params}} = binary_to_term(Package),
    #     R = erlang:apply(Mod, F, Params),
    #     MsgBody = term_to_binary(#reply{from = From, reply_code = 1004, reply_data = R}),
    #     Bin = glib_pb:encode_Msg(?CMD_CALL_FUN_REPLY, MsgBody),
    #     self() ! {reply, Bin},
    #     ok;

    # {request,#{from => {<15334.2418.0>,#Ref<15334.0.1.13621>},pid => <15334.3486.0>},
    #         call_fun,
    #         {glib,replace,["helloworld","world"," you"]}}}

    def action(Eglib.cmd_CALL_FUN, package) do
        # Elog.print({Eglib.cmd_CALL_FUN, package})
        {_, from, _, {mod, f, params}} = :erlang.binary_to_term(package)
        # Elog.print({Eglib.cmd_CALL_FUN, req})
        #     MsgBody = term_to_binary(#reply{from = From, reply_code = 1004, reply_data = R}),
        r = :erlang.apply(mod, f, params)
        msg_body = :erlang.term_to_binary({:reply, from, 1004, r})
        #     Bin = glib_pb:encode_Msg(?CMD_CALL_FUN_REPLY, MsgBody),
        bin = :glib_pb.encode_Msg(Eglib.cmd_CALL_FUN_REPLY, msg_body)
        #     self() ! {reply, Bin},
        send :erlang.self(), {:reply, bin}
        
        :ok
    end
      
    #   action(?CMD_CALL_FUN_REPLY, Package) ->
    #     % ?LOG({?CMD_CALL_FUN_REPLY, Package}),
    #     #reply{from = From, reply_code = _Cmd, reply_data = Payload} = binary_to_term(Package),
    #     % ?LOG(#{from => From, payload => Payload}),
    #     % #{from => {{<0.517.0>,#Ref<0.0.1.8353>},<0.828.0>},payload => "hello you"}
    #     glib:safe_reply(From, Payload),
    #     ok;
    # :wsc_call.test()
    def action(Eglib.cmd_CALL_FUN_REPLY, package) do
        # Elog.print({Eglib.cmd_CALL_FUN_REPLY, package})
        {_, from, _, payload} = :erlang.binary_to_term(package)
        :glib.safe_reply(from, payload)
        :ok
    end
      
    #   action(Action, Package) -> 
    #     ?LOG({action, Action, Package}),
    #     ok.
    def action(cmd, package) do
        Elog.print({cmd, package})
        :ok
    end
end