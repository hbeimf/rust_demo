defmodule Gwc.GwcInit do
    require Elog

    @moduledoc """
    Documentation for Gwc.
    """
  
    @doc """
    Hello world.
  
    ## Examples
  
        iex> Gwc.hello
        :world
  
    """
    def hello do
      :world
    end

    

    # init() ->
    #     start_pool(),
    #     regiter_gw_2_gwc(),
    #     ok.
    def init do 
        # Elog.log('GwcInit', {:log_test, 1, 2})
        # Elog.print({:log_test, 1, 2})
        start_pool()
        regiter_gw_2_gwc()
        :init
    end  
 
    #   register_gw_2_gwc([], _Size, _WorkId) ->
    #     ok;
    #   register_gw_2_gwc([{_, Pid, _, _}|OtherWork], Size, WorkId) ->
    #     RegisterConfig = register_config(Size, WorkId),
    #     Register = wsc_common:req(register_gw, RegisterConfig),
    #     Msg = glib_pb:encode_Msg(?CMD_REGISTER, Register),
    #     Pid ! {init_send, Msg},
    #     register_gw_2_gwc(OtherWork, Size, WorkId+1).
    def register_gw_2_gwc([], _, _) do 
        :ok
    end
    def register_gw_2_gwc([{_, pid, _, _}|other_work], size, work_id) do 
        #     RegisterConfig = register_config(Size, WorkId),
        register_config = register_config(size, work_id)
        #     Register = wsc_common:req(register_gw, RegisterConfig),
        register = :wsc_common.req(:register_gw, register_config)
        #     Msg = glib_pb:encode_Msg(?CMD_REGISTER, Register),
        msg = :glib_pb.encode_Msg(Eglib.cmd_REGISTER, register)
        #     Pid ! {init_send, Msg},
        send pid, {:init_send, msg}
        #     register_gw_2_gwc(OtherWork, Size, WorkId+1).
        register_gw_2_gwc(other_work, size, work_id + 1) 
    end
      
    #   regiter_gw_2_gwc() ->
    #     ConfigList = glib_config:hubs(),
    #     lists:foreach(fun(#{pool_id := PoolId, addr := _Addr}) -> 
    #       Works = wsc_common:works(PoolId),
    #       register_gw_2_gwc(Works, erlang:length(Works), 1)
    #     end ,ConfigList),
    #     ok.
    def regiter_gw_2_gwc() do 
        config_list = :glib_config.hubs()
        :lists.foreach(fn(%{pool_id: v_pool_id, addr: _v_addr}) -> 
            works = :wsc_common.works(v_pool_id)
            register_gw_2_gwc(works, :erlang.length(works), 1)
        end, config_list)
    end
    
      

    #   start_pool() -> 
    #     ConfigList = glib_config:hubs(),
    #     lists:foreach(
    #       fun(#{pool_id := PoolId, addr := Addr}) -> 
    #         ?LOG({PoolId, Addr}),
    #         wsc_common:dynamic_start_pool(PoolId, Addr, gwc_action),
    #         ok
    #       end, ConfigList).
    def start_pool() do 
        Elog.print('start_pool')
        config_list = :glib_config.hubs()
        :lists.foreach(fn (%{pool_id: v_pool_id, addr: v_addr}) -> 
            Elog.print({v_pool_id, v_addr})
            :wsc_common.dynamic_start_pool(v_pool_id, v_addr, :gwc_action)
            :ok
        end, config_list)
    end
      
    #   %%config =================
    #   register_config(Size, WorkId) ->
    #     ClusterId = cluster(sys_config:get_config(node, cluster_id)),
    #     #{
    #       % cluster_id => sys_config:get_config(node, cluster_id)
    #       cluster_id => ClusterId
    #       , node_id => sys_config:get_config(node, node_id)
    #       , size => Size
    #       , work_id => WorkId
    #     }.
    def register_config(size, work_id) do 
        cluster_id = cluster(:sys_config.get_config(:node, :cluster_id))
        %{
            :cluster_id => cluster_id,
            :node_id => :sys_config.get_config(:node, :node_id),
            :size => size,
            :work_id => work_id
        }
    end

      
    #   cluster(1) ->
    #     pool_gw_1;
    #   cluster(2) ->
    #     pool_gw_2;
    #   cluster(3) ->
    #     pool_gw_3;
    #   cluster(4) ->
    #     pool_gw_4;
    #   cluster(5) ->
    #     pool_gw_5;
    #   cluster(6) ->
    #     pool_gw_6;
    #   cluster(7) ->
    #     pool_gw_7;
    #   cluster(8) ->
    #     pool_gw_8;
    #   cluster(9) ->
    #     pool_gw_9;
    #   cluster(10) ->
    #     pool_gw_10;
    #   cluster(_) ->
    #     pool_gw_100.

    # Gwc.GwcInit.cluster(2)
    def cluster(1), do: :pool_gw_1 
    def cluster(2), do: :pool_gw_2
    def cluster(3), do: :pool_gw_3 
    def cluster(4), do: :pool_gw_4 
    def cluster(5), do: :pool_gw_5 
    def cluster(6), do: :pool_gw_6 
    def cluster(7), do: :pool_gw_7 
    def cluster(8), do: :pool_gw_8 
    def cluster(9), do: :pool_gw_9 
    def cluster(10), do: :pool_gw_10 
    def cluster(_), do: :pool_gw_100 
        

        

  end
  