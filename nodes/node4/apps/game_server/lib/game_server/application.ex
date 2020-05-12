defmodule GameServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    start_game_server()
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: GameServer.Worker.start_link(arg)
      # {GameServer.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GameServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_game_server() do 
    dispatch = :cowboy_router.compile([
      {:_, [
        {'/ws', :ws_handler, []},	
        {'/api/gm/statue', :handler_statue, []}	
      ]}
    ])
  
    {:ok, config_list} = :sys_config.get_config(:http)
    {_, {:port, port}, _} = :lists.keytake(:port, 1, config_list)
  
  
    {:ok, _} = :cowboy.start_http(:http, 100, [{:port, port}, {:max_connections, 1000000}], [{:env, [{:dispatch, dispatch}]}])
    :ok
  end
end
