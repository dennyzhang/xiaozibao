%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : snake_worker_sup.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-04-09>
%%% Updated: Time-stamp: <2013-02-26 15:24:13>
%%%-------------------------------------------------------------------
-module(snake_worker_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([get_queue_childspec/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 50000, Type, [I]}).
-define(CHILD_ARG(Id, Module, Args, Type),
        {Id, {Module, start_link, [Args]}, permanent, 50000, Type, [Module]}).
%%% ------------------------ Supervisor callbacks -----------------------
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    %% default services to be monitored by supervisor
    ThriftService = ?CHILD(snake_worker_thrift, worker),
    Rabbitmq_server = snake_utility:get_option(rabbitmq_server),
    Queue_list = snake_utility:list_queues(),
    Listener_service_list = get_queue_childspec(Queue_list),
    {ok,{{one_for_one,5,10}, Listener_service_list}}.

get_queue_childspec(Queue_list) ->
    Script_domain = snake_utility:get_script_domain(),
    Queue_listener_list = snake_utility:parse_queue_worker(Queue_list, Script_domain),
    lists:map(fun({Worker_type, Parallel_count, Queue_listener_module, Queue_listener_name, Queue_name}) ->
                      ?CHILD_ARG(Queue_listener_name, Queue_listener_module,
                                 [Queue_listener_name, Queue_name, Worker_type,
                                  snake_utility:get_parallel_count(Parallel_count)], worker)
              end, Queue_listener_list).

%%% File : snake_worker_sup.erl ends
