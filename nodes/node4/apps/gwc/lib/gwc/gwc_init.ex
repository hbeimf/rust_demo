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
      
    #   regiter_gw_2_gwc() ->
    #     ConfigList = glib_config:hubs(),
    #     lists:foreach(fun(#{pool_id := PoolId, addr := _Addr}) -> 
    #       Works = wsc_common:works(PoolId),
    #       register_gw_2_gwc(Works, erlang:length(Works), 1)
    #     end ,ConfigList),
    #     ok.
    def regiter_gw_2_gwc() do 

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
    def register_config() do 

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
    def cluster() do 

    end
        

  end
  