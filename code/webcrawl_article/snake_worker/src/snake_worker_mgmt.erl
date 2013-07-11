%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : snake_worker_mgmt.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-03-20>
%%% Updated: Time-stamp: <2013-02-26 15:25:58>
%%%-------------------------------------------------------------------
-module(snake_worker_mgmt).
-behaviour(gen_srvmgmt).
-include_lib("snake_header.hrl").
-record(shopex_smc_info, {key, value}).

-compile(export_all). %% TODO remove this wild export later
%% ------------------------------------------------------------------
%% gen_srvmgmt Interfaces
%% ------------------------------------------------------------------
-export([help/0, init_system/1, join_system/1, upgrade/1]).
help() ->
    error_logger:info_msg(["snake_worker_mgmt:init_system([]).\n",
       "\t-- No special action is needed.\n",
       "snake_worker_mgmt:join_system([]).\n",
       "\t-- No special action is needed.\n",
       "snake_worker_mgmt:upgrade([]).\n",
       "\t-- Not needed yet.\n"]).

init_system(_Options) ->
    mnesia:start(),
    mnesia:change_table_copy_type(schema, node(), disc_copies),
    [install_table(T) || T <- all_tables()],
    mnesia:change_table_copy_type(shopex_smc_info, node(), ram_copies),
    error_logger:info_msg("install table shopex_smc_info.\n"),
    ok.

join_system(Node) ->
    clear_db(),
    case rpc:call(Node,snake_worker_mgmt,add_node,[node()]) of
	ok -> timer:sleep(1500),io:format("cluster joined\n");
	{error, Why} ->  timer:sleep(1500),io:format("failed: ~s\n",[Why]);
	Other ->  timer:sleep(1500),io:format("Unknow status: ~p\n",[Other])
    end.


add_node(Node)->
    pong = net_adm:ping(Node),
    mnesia:change_config(extra_db_nodes, [Node]),
    mnesia:change_table_copy_type(schema, Node, disc_copies),
    rpc:call(Node,mnesia,wait_for_tables,[schema]),
    L = [mnesia:add_table_copy(T, Node, disc_copies) || T <- all_tables()],
    lists:foldl(fun({atomic, ok}, Acc0) ->
			Acc0;
		   (H, ok)  ->
			[H];
		   (H, Acc0) ->
			[H|Acc0]
		end,ok, L).


clear_db()->
    mnesia:stop(),
    mnesia:delete_schema([node()]),
    mnesia:start(),
    ok.


upgrade(_Options) ->
    mnesia:start(),
    mnesia:change_table_copy_type(schema, node(), disc_copies),
    [install_table(T) || T <- all_tables()],
    mnesia:change_table_copy_type(shopex_smc_info, node(), ram_copies),
    error_logger:info_msg("install table shopex_smc_info.\n"),
    ok.
%%% File : snake_generator_mgmt.erl ends

all_tables() ->
    [shopex_smc_info].

install_table(Table)->
    install_table([node()],Table).

install_table(Nodes,shopex_smc_info)->
    mnesia:create_table(shopex_smc_info,[
        {type,set},
        {ram_copies, Nodes},
        {attributes, record_info(fields, shopex_smc_info)}
    ]).
