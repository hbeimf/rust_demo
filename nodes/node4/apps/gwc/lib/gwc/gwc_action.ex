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
end