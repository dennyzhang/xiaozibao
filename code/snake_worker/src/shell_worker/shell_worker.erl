%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : shell_worker.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-04-26>
%%% Updated: Time-stamp: <2013-03-05 01:13:29>
%%%-------------------------------------------------------------------
-module(shell_worker).

-include("defined.hrl").
-define(SHELL_TIMEOUT, 30000).
-define(MIN_SLEEP, 2).
-define(RANDOM_SLEEP, 120).
-compile(export_all).

spawn_worker(Worker_state) ->
    {ok, Worker_state2} = start_worker(Worker_state),
    do_work(Worker_state2),
    ok.

start_worker(Worker_state) ->
    process_flag(trap_exit, true),
    Shell_command = Worker_state#worker_state.task_id,
    random:seed(erlang:now()),
    Random_sleep = random:uniform(?RANDOM_SLEEP) + ?MIN_SLEEP,
    error_logger:info_msg("[~s:~p] Randm Sleep for ~p seconds, before run command: ~s~n",
                          [Worker_state#worker_state.listener_name, ?LINE, Random_sleep, Shell_command]),
    timer:sleep(Random_sleep*1000),
    Port = open_port({spawn, Shell_command}, [stderr_to_stdout, exit_status, use_stdio, {env, []}]),
    Worker_state2 = Worker_state#worker_state{worker_id = Port,
                                              error_status = start_work,
                                              error_message = ""},
    snake_utility:log_job_status(Worker_state2),
    {ok, Worker_state2}.

do_work(Worker_state) ->
    Port = Worker_state#worker_state.worker_id,
    receive
        {Port, {exit_status, 0}} ->
            Worker_state2 = Worker_state#worker_state{error_status = finish_task_ok,
                                                      error_message = "Finished correctly"},
            snake_utility:log_job_status(Worker_state2),
            gen_server:call(Worker_state#worker_state.listener_name, {finish_task, Worker_state2});
        {Port, {exit_status, _Status}} ->
            Worker_state2 = Worker_state#worker_state{error_status = finish_task_fail},
            error_logger:error_msg("[~p:~p] Fail to run task(~s), error_message:~s~n",
                                   [?MODULE, ?LINE, Worker_state2#worker_state.task_id, Worker_state2#worker_state.error_message]),
            snake_utility:log_job_status(Worker_state2);
        %% don't ack, if task fails
        %% gen_server:call(Worker_state#worker_state.listener_name, {finish_task, Worker_state2});
        {Port, {data, Data}} ->
            %% TODO: return stdout to caller
            Error_message = Worker_state#worker_state.error_message ++ "\n" ++ Data,
            Worker_state2 = Worker_state#worker_state{error_message = Error_message},
            do_work(Worker_state2);
        Any ->
            error_logger:error_msg("[~p:~p:~p:~p] unknown message:~p~n",[self(), calendar:now_to_local_time(now()), ?MODULE, ?LINE, Any])
    after ?SHELL_TIMEOUT ->
            Worker_state2 = Worker_state#worker_state{error_status = finish_task_timeout,
                                                      error_message = "Worker timeout"},
            snake_utility:log_job_status(Worker_state2),
            gen_server:call(Worker_state2#worker_state.listener_name, {finish_task, Worker_state2})
    end,
    ok.
%%% File : shell_worker.erl ends
