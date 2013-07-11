%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : snake_worker.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-04-09>
%%% Updated: Time-stamp: <2013-02-26 15:24:53>
%%%-------------------------------------------------------------------
-module(snake_worker).
-export([start/0]).
-compile([export_all]).

start()->
    application:start(?MODULE).
%%% File : snake_worker.erl ends
