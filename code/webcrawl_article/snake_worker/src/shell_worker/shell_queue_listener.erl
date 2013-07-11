%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : shell_queue_listener.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-04-26>
%%% Updated: Time-stamp: <2013-02-26 15:25:59>
%%%-------------------------------------------------------------------
-module(shell_queue_listener).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-include_lib("amqp_client/include/amqp_client.hrl").
-include("defined.hrl").

%% default task timeout is 20 seconds
-define(TASK_TIMEOUT, 20000).

-compile(export_all). %% TODO, remove this wild export
%%% ------------------------ Gen_server callbacks -----------------------
start_link([Queue_listener_name, Queue_name, Task_type, Parallel_count]) ->
    gen_server:start_link({local, Queue_listener_name}, ?MODULE, [Queue_listener_name, Queue_name, Task_type, Parallel_count], []).

init([Queue_listener_name, Queue_name, Task_type, Parallel_count]) ->
    process_flag(trap_exit, true),
    Rabbitmq_server = snake_utility:get_option(rabbitmq_server),
    {Connection, Channel} = snake_utility:listen_queue(Rabbitmq_server, Queue_name, Parallel_count),
    State = #queue_listener_state{rabbitmq_server = Rabbitmq_server,
                                  queue_name = Queue_name,
                                  connection = Connection,
                                  channel = Channel,
                                  task_type = Task_type,
                                  listener_name = Queue_listener_name},
    error_logger:info_msg("[~p:~p:~p] connect to rabbitmq, Queue:~p, Connection:~p, Channel:~p~n",
                          [self(), State#queue_listener_state.listener_name, ?LINE, Queue_name, Connection, Channel]),
    {ok, State}.

handle_call({finish_task, Worker_state}, _From, State) ->
    snake_utility:ack_queue(Worker_state, State#queue_listener_state.channel),
    {reply, ok, State};

handle_call(Request, _From, State) ->
    error_logger:error_msg("[~p:~p:~p] receive unknown syc message:~p~n",
                           [self(), State#queue_listener_state.listener_name, ?LINE, Request]),
    {reply, ok, State}.

handle_cast(Message, State) ->
    error_logger:error_msg("[~p:~p:~p] receive unknown async message:~p~n",
                           [self(), State#queue_listener_state.listener_name, ?LINE, Message]),
    {noreply, State}.

handle_info({#'basic.deliver'{delivery_tag = Queue_message_tag}, #amqp_msg{payload = Body}}, State) ->
    %% error_logger:info_msg("[~p:~p] here:~p~n",[?MODULE, ?LINE, Body]),
    Shell_command = binary_to_list(Body),
    Worker_state = #worker_state{task_id = Shell_command,
                                 task_type = State#queue_listener_state.task_type,
                                 queue_message_tag = Queue_message_tag,
                                 error_status = new_task,
                                 error_message = "",
                                 listener_name = State#queue_listener_state.listener_name},
    snake_utility:log_job_status(Worker_state),
    spawn_link(fun() -> shell_worker:spawn_worker(Worker_state) end),
    {noreply, State};
handle_info(#'basic.consume_ok'{consumer_tag = Tag}, State) ->
    error_logger:info_msg("[~p:~p:~p] connected to queue of consumer_tag:~p~n",
                          [self(), State#queue_listener_state.listener_name, ?LINE, Tag]),
    {noreply, State};
handle_info({'EXIT', _Worker_pid, normal}, State) ->
    {noreply, State};
handle_info(Info, State) ->
    error_logger:error_msg("[~p:~p:~p] recive unexpected message:~p~n",
                           [self(), State#queue_listener_state.listener_name, ?LINE, Info]),
    {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVsn, State, _Extra) -> {ok, State}.
%%% ------------------------ Internal functions -------------------------
%%% File : shell_queue_listener.erl ends
