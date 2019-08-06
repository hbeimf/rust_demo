BASEDIR = $(shell pwd)
REBAR = rebar3
RELPATH = _build/default/rel/riak_learn
PRODRELPATH = _build/prod/rel/riak_learn
DEV1RELPATH = _build/dev1/rel/riak_learn
DEV2RELPATH = _build/dev2/rel/riak_learn
DEV3RELPATH = _build/dev3/rel/riak_learn
APPNAME = riak_learn
SHELL = /bin/bash

release:
	$(REBAR) release
	mkdir -p $(RELPATH)/../riak_learn_config
	[ -f $(RELPATH)/../riak_learn_config/riak_learn.conf ] || cp $(RELPATH)/etc/riak_learn.conf  $(RELPATH)/../riak_learn_config/riak_learn.conf
	[ -f $(RELPATH)/../riak_learn_config/advanced.config ] || cp $(RELPATH)/etc/advanced.config  $(RELPATH)/../riak_learn_config/advanced.config

console:
	cd $(RELPATH) && ./bin/riak_learn console

prod-release:
	$(REBAR) as prod release
	mkdir -p $(PRODRELPATH)/../riak_learn_config
	[ -f $(PRODRELPATH)/../riak_learn_config/riak_learn.conf ] || cp $(PRODRELPATH)/etc/riak_learn.conf  $(PRODRELPATH)/../riak_learn_config/riak_learn.conf
	[ -f $(PRODRELPATH)/../riak_learn_config/advanced.config ] || cp $(PRODRELPATH)/etc/advanced.config  $(PRODRELPATH)/../riak_learn_config/advanced.config

prod-console:
	cd $(PRODRELPATH) && ./bin/riak_learn console

compile:
	$(REBAR) compile

clean:
	$(REBAR) clean

test:
	$(REBAR) ct

devrel1:
	$(REBAR) as dev1 release
	mkdir -p $(DEV1RELPATH)/../riak_learn_config
	[ -f $(DEV1RELPATH)/../riak_learn_config/riak_learn.conf ] || cp $(DEV1RELPATH)/etc/riak_learn.conf  $(DEV1RELPATH)/../riak_learn_config/riak_learn.conf
	[ -f $(DEV1RELPATH)/../riak_learn_config/advanced.config ] || cp $(DEV1RELPATH)/etc/advanced.config  $(DEV1RELPATH)/../riak_learn_config/advanced.config

devrel2:
	$(REBAR) as dev2 release
	mkdir -p $(DEV2RELPATH)/../riak_learn_config
	[ -f $(DEV2RELPATH)/../riak_learn_config/riak_learn.conf ] || cp $(DEV2RELPATH)/etc/riak_learn.conf  $(DEV2RELPATH)/../riak_learn_config/riak_learn.conf
	[ -f $(DEV2RELPATH)/../riak_learn_config/advanced.config ] || cp $(DEV2RELPATH)/etc/advanced.config  $(DEV2RELPATH)/../riak_learn_config/advanced.config

devrel3:
	$(REBAR) as dev3 release
	mkdir -p $(DEV3RELPATH)/../riak_learn_config
	[ -f $(DEV3RELPATH)/../riak_learn_config/riak_learn.conf ] || cp $(DEV3RELPATH)/etc/riak_learn.conf  $(DEV3RELPATH)/../riak_learn_config/riak_learn.conf
	[ -f $(DEV3RELPATH)/../riak_learn_config/advanced.config ] || cp $(DEV3RELPATH)/etc/advanced.config  $(DEV3RELPATH)/../riak_learn_config/advanced.config

devrel: devrel1 devrel2 devrel3

dev1-attach:
	$(BASEDIR)/_build/dev1/rel/riak_learn/bin/$(APPNAME) attach

dev2-attach:
	$(BASEDIR)/_build/dev2/rel/riak_learn/bin/$(APPNAME) attach

dev3-attach:
	$(BASEDIR)/_build/dev3/rel/riak_learn/bin/$(APPNAME) attach

dev1-console:
	$(BASEDIR)/_build/dev1/rel/riak_learn/bin/$(APPNAME) console

dev2-console:
	$(BASEDIR)/_build/dev2/rel/riak_learn/bin/$(APPNAME) console

dev3-console:
	$(BASEDIR)/_build/dev3/rel/riak_learn/bin/$(APPNAME) console

devrel-clean:
	rm -rf _build/dev*/rel

devrel-start:
	for d in $(BASEDIR)/_build/dev*; do $$d/rel/riak_learn/bin/$(APPNAME) start; done

devrel-join:
	for d in $(BASEDIR)/_build/dev{2,3}; do $$d/rel/riak_learn/bin/$(APPNAME)-admin cluster join riak_learn1@127.0.0.1; done

devrel-cluster-plan:
	$(BASEDIR)/_build/dev1/rel/riak_learn/bin/$(APPNAME)-admin cluster plan

devrel-cluster-commit:
	$(BASEDIR)/_build/dev1/rel/riak_learn/bin/$(APPNAME)-admin cluster commit

devrel-status:
	$(BASEDIR)/_build/dev1/rel/riak_learn/bin/$(APPNAME)-admin member-status

devrel-ping:
	for d in $(BASEDIR)/_build/dev*; do $$d/rel/riak_learn/bin/$(APPNAME) ping; true; done

devrel-stop:
	for d in $(BASEDIR)/_build/dev*; do $$d/rel/riak_learn/bin/$(APPNAME) stop; true; done

start:
	$(BASEDIR)/$(RELPATH)/bin/$(APPNAME) start

stop:
	$(BASEDIR)/$(RELPATH)/bin/$(APPNAME) stop

attach:
	$(BASEDIR)/$(RELPATH)/bin/$(APPNAME) attach


push:
	git add .
	git commit -m 'x'
	git push

run: release console
