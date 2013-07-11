CC      := gcc
CFLAGS  := -g -O2 -DPACKAGE_NAME=\"snake_worker\" -DPACKAGE_TARNAME=\"snake_worker\" -DPACKAGE_VERSION=\"1.0\" -DPACKAGE_STRING=\"snake_worker\ 1.0\" -DPACKAGE_BUGREPORT=\"markfilebat@126.com\" -DPACKAGE_URL=\"\" -DCPU_VENDOR_OS=\"x86_64-unknown-linux-gnu\" LD_SHARED       := @LD_SHARED@

DESTDIR :=
prefix := /usr/local/
exec_prefix := ${prefix}
ecae_user := @user@
bindir := ${exec_prefix}/bin
libexecdir := ${exec_prefix}/libexec
sysconfdir := ${prefix}/etc
libdir := ${exec_prefix}/lib
includedir := ${prefix}/include
mandir := ${datarootdir}/man
datarootdir = ${prefix}/share
datadir = ${datarootdir}
INSTALL := /usr/bin/install -c
ERTS_VSN := @ERLANG_ERTS_VER@
SNAKE_WORKER_VSN := svn
REBAR := ./rebar

.PHONY: all deps doc test clean release start

all: deps version 
	$(REBAR) compile

version:
	@echo "-define(snake_worker_vsn, \"${SNAKE_WORKER_VSN}\")." | tee include/vsn.hrl

deps:
	$(REBAR) get-deps

doc:
	$(REBAR) doc skip_deps=true

test:
	$(REBAR) eunit skip_deps=true

clean:
	$(REBAR) clean

dialyzer: all test
	dialyzer --src src/*.erl deps/*/src/*.erl

release: all
	$(REBAR) generate

install:
	$(INSTALL) -d ${DESTDIR}/usr/local/ ${DESTDIR}${exec_prefix}/bin
	cp -r rel/snake_worker ${DESTDIR}/usr/local/
	$(INSTALL) -d scripts ${DESTDIR}/usr/local//snake_worker/scripts
	cp -rf scripts/* ${DESTDIR}/usr/local//snake_worker/scripts/
	chmod -R +x ${DESTDIR}/usr/local//snake_worker/scripts/*
	$(INSTALL) snake_workerd ${DESTDIR}${exec_prefix}/bin
	$(INSTALL) snake_workerctl ${DESTDIR}${exec_prefix}/bin
