defmodule MainApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # __LINE__

    # :sys_log.write_line(__MODULE__,  __ENV__.line, 'start_log_test', {:log_test, 1, 2, __ENV__.file})

    require Elog
    Elog.log('XX', {:log_test, 1, 2})
    
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: MainApp.Worker.start_link(arg)
      # {MainApp.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MainApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
