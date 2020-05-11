# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"rlubA(0OV:^9K$p5IfNxC<ca(Xzb97su,jzd,qHfLfSd/6wg|tM.Pt]9|likxPU<"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"b`PdV$3,vnUd<[4x6I`>w}V=*qM0)WM&wXiF5[a@vybXd,c97/bR97d_k|]ljOHF"
end

environment :master do
  set include_erts: true
  set include_src: false
  set cookie: :"zrY/QSYYve.KqMZ5Wn*aCI*^(?0(GV0hS:wtD2`As~7iv^E5<iGR3^ebCM~5vTNl"
  set vm_args: "config/vm_master.args"
end

environment :slave do
  set include_erts: true
  set include_src: false
  set cookie: :"zrY/QSYYve.KqMZ5Wn*aCI*^(?0(GV0hS:wtD2`As~7iv^E5<iGR3^ebCM~5vTNl"
  set vm_args: "config/vm_slave.args"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

# [kernel,stdlib,compiler,elixir,iex,mix,crypto,asn1,public_key,ssl,inets,hex,
#  logger,esnowflake,zucchini,glib,main_app]

release :node4 do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    main_app: :permanent
  ]
end

