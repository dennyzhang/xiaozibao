%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : snake_utility.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-04-26>
%%% Updated: Time-stamp: <2013-02-26 15:24:44>
%%%-------------------------------------------------------------------
-module(snake_utility).

-compile(export_all).
-include("defined.hrl").
-include_lib("amqp_client/include/amqp_client.hrl").
-define(TASK_FAILED_START, "TASK FAILED TO START").
-define(TASK_SUCCEED, "TASK SUCCEED").
-define(TASK_FAILED, "TASK FAILED").
-define(TASK_TIMEOUT, "TASK TIMEOUT").
-define(TASK_UNKOWN, "TASK FAILED WITH UNKNOWN REASON").
-define(TASK_PROGRESS, "TASK PROGRESS").

list_queues() ->
    Command ="sudo rabbitmqctl list_queues | grep snake_worker | awk -F'\t' '{print $1}'",
    {ok, Str} = cmd(Command, []),
    L = string:tokens(Str, "\n"),
    L.

listen_queue(Hostname, Queue_name, Prefetch_count) ->
    {Connection, Channel} = build_mq_connection(Hostname, Queue_name),
    amqp_channel:call(Channel, #'basic.qos'{prefetch_count = Prefetch_count}),
    #'basic.consume_ok'{consumer_tag = _Tag} =
        amqp_channel:subscribe(Channel, #'basic.consume'{queue = list_to_binary(Queue_name)}, self()),
    {Connection, Channel}.

%% parse_snake_queue("snake_worker-shell#2#d1#name1")
%% -> {ok, ["php_loop", 2, "d1", "name1"]} | {error, invalid_queue_name}
parse_snake_queue(Queue) ->
    case Queue of
        "snake_worker-"++ Str ->
            try
                [Queue_worker, Parallel_count_str, Domain, Queue_postfix] = string:tokens(Str, "#"),
                {Parallel_count, []} = string:to_integer(Parallel_count_str),
                {ok, [Queue_worker, Parallel_count, Domain, Queue_postfix]}
            catch _:_Error->
                    {error, invalid_queue}
            end;
        _ ->
            {error, invalid_queue}
    end.

%% Return [{Queue_listener_module, Queue_listener_name, Queue_name}]
%% Sample: parse_queue_worker(["snake_worker-curl#2#d1#1"]) ->
%% [{curl_queue_listener, 2, snake_worker_curl_d1_1, "snake_worker-curl#d1#1"}]
parse_queue_worker(Queue_list, Script_domain) ->
    L = lists:map(fun(Queue_name) ->
                          case parse_snake_queue(Queue_name) of
                              {ok, [Queue_worker, Parallel_count, Domain, Queue_postfix]} ->
                                  case Domain of
                                      Script_domain ->
                                          {"ecae_"++Queue_worker, Parallel_count,
                                           list_to_atom(Queue_worker++"_queue_listener"),
                                           list_to_atom(Queue_worker++"_queue_listener_"++integer_to_list(Parallel_count)
                                                        ++"_" ++ Domain++"_"++Queue_postfix),
                                           Queue_name};
                                      _ -> none
                                  end;
                              {error, invalid_queue} ->
                                  error_logger:error_msg("[~p][~p:~p:~p] Queue name invalid:~p~n",[self(), calendar:now_to_local_time(now()), ?MODULE, ?LINE, Queue_name]),
                                  none
                          end
                  end, Queue_list),
    lists:filter(fun(X) -> X =/= none end, L).

get_option(Option) ->
    case application:get_env(snake_worker, Option) of
        undefined -> throw(configuration_error);
        {ok, Val} -> Val
    end.

get_script_domain() ->
    Node_name = snake_utility:get_option(nodename),
    {Script_domain, _Server_list} = get_nodelist_in_same_domain(Node_name),
    Script_domain.

get_nodelist_in_same_domain(Node_name) ->
    case application:get_env(snake_worker, host_domain) of
        undefined -> throw(configuration_error);
        {ok, Script_list} ->
            L = lists:filter(fun({_Script_domain, Server_list}) ->
                                     lists:any(fun(X) -> X=:= Node_name end, Server_list)
                             end, Script_list),
            case length(L) of
                0 -> error(script_domain_not_found);
                1 ->
                    [{Script_domain, _Server_list}] = L,
                    {Script_domain, _Server_list};
                _ -> error(script_domain_configure_error)
            end
    end.

get_parallel_count(Max_parallel_count) ->
    L = get_snake_servers_in_same_domain(),
    Div = Max_parallel_count div length(L),
    case Max_parallel_count rem length(L) of
        0 -> Div;
        _ -> Div + 1
    end.

get_snake_servers_in_same_domain() ->
    Node_name = snake_utility:get_option(nodename),
    {_Script_domain, Server_list} = get_nodelist_in_same_domain(Node_name),
    Snake_servers_str = get_option(snake_worker_servers),
    Snake_servers = lists:map(fun(X) ->
                                      [Short_name | _ ] = string:tokens(X, "."),
                                      Short_name
                              end,
                              string:tokens(Snake_servers_str, " ")),
    L = lists:filter(fun(Server) ->
                             lists:any(fun(X) -> Server =:= X end,
                                       Snake_servers)
                     end,
                     Server_list),
    case L of
        0 -> error(config_error_snake_servers);
        _ -> true
    end,
    L.

list_queue_listener() ->
    Registered_names = registered(),
    lists:filter(fun(Name) ->
                         0 =/= string:str(atom_to_list(Name), "listener")
                 end, Registered_names).

decode_worker_state(Worker_state) when is_record(Worker_state, worker_state) ->
    %% TODO better implementation
    lists:flatten(io_lib:format("Site_id:~p, message_id:~p, task_id:~p, task_arg:~p, queue_message_tag:~p, worker_id:~p, error_status:~p, error_message:~p, listener_name:~p",
                                [Worker_state#worker_state.site_id,
                                 Worker_state#worker_state.message_id,
                                 Worker_state#worker_state.task_id,
                                 Worker_state#worker_state.task_arg,
                                 Worker_state#worker_state.queue_message_tag,
                                 Worker_state#worker_state.worker_id,
                                 Worker_state#worker_state.error_status,
                                 Worker_state#worker_state.error_message,
                                 Worker_state#worker_state.listener_name])).

log_job_status(Worker_state) when is_record(Worker_state, worker_state) ->
    Log_category = Worker_state#worker_state.task_type,
    Arg = [Worker_state#worker_state.message_id,
           Worker_state#worker_state.site_id,
           Worker_state#worker_state.listener_name,
           Worker_state#worker_state.task_id,
           Worker_state#worker_state.task_arg,
           Worker_state#worker_state.error_status,
           Worker_state#worker_state.error_message],
    case Worker_state#worker_state.error_status of
        new_task ->
            Format = "~s ~p New task, listener_name:~p, task_id:~p, " ++
                "task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        assign_worker_manager ->
            Format = "~s ~p Find related worker manager for the new task, " ++
                "listener_name:~p, task_id:~p, task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        assign_worker ->
            Format = "~s ~p Assign a worker for the new task, listener_name:~p, " ++
                "task_id:~p, task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        start_work_fail ->
            Format = "~s ~p Fail to start task, listener_name:~p, task_id:~p, task_arg:~p, " ++
                "error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        start_work ->
            Format = "~s ~p Worker start to work, listener_name:~p, task_id:~p, " ++
                "task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        finish_task_ok ->
            Format = "~s ~p Task finished correctly, listener_name:~p, task_id:~p, " ++
                "task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        progress_task->
            Format = "~s ~p Task exec, listener_name:~p, task_id:~p, " ++
                "task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        finish_task_fail ->
            Format = "~s ~p Task failed, listener_name:~p, task_id:~p, task_arg:~p, " ++
                "error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        finish_task_timeout ->
            Format = "~s ~p Task failed for timeout, listener_name:~p, task_id:~p, " ++
                "task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg);
        ack_message_queue ->
            Format = "~s ~p Ack message queue for the task, listener_name:~p, task_id:~p, " ++
                "task_arg:~p, error_status:~p, error_message:~p~n",
            log_job_status(Log_category, Format, Arg),
            case Worker_state#worker_state.error_message of
                start_work_fail ->
                    log_job_status(Log_category, "~s ~p ~s~n",
                                   [Worker_state#worker_state.message_id, Worker_state#worker_state.site_id, ?TASK_FAILED_START]);
                finish_task_fail ->
                    log_job_status(Log_category, "~s ~p ~s~n",
                                   [Worker_state#worker_state.message_id, Worker_state#worker_state.site_id, ?TASK_FAILED]);
                finish_task_ok ->
                    log_job_status(Log_category, "~s ~p ~s~n",
                                   [Worker_state#worker_state.message_id, Worker_state#worker_state.site_id, ?TASK_SUCCEED]);
                finish_task_timeout ->
                    log_job_status(Log_category, "~s ~p ~s~n",
                                   [Worker_state#worker_state.message_id, Worker_state#worker_state.site_id, ?TASK_TIMEOUT]);
                _ ->
                    error_logger:error_msg("[~p:~p:~p:~p] Invalid log. Worker_state:~p~n",
                                           [self(), calendar:now_to_local_time(now()),
                                            ?MODULE, ?LINE, snake_utility:decode_worker_state(Worker_state)]),
                    log_job_status(Log_category, "~s ~p ~s~n",
                                   [Worker_state#worker_state.message_id, Worker_state#worker_state.site_id, ?TASK_UNKOWN])
            end
    end.

log_job_status(Log_category, Format, Arg) ->
    error_logger:info_report(Log_category, lists:flatten(io_lib:format(Format, Arg))).

dump_all_message(Worker_state) when is_record(Worker_state, worker_state) ->
    case process_info(self(), messages) of
        {messages, []} -> ok;
        {messages, Messages} ->
            error_logger:error_msg("[~p:~p:~p:~p] for worker:~p, Unknown messages:~p~n",
                                   [self(), calendar:now_to_local_time(now()),
                                    ?MODULE, ?LINE, snake_utility:decode_worker_state(Worker_state), Messages])
    end.

%% #################### private functions ##########################
ack_queue(Worker_state, Channel) when is_record(Worker_state, worker_state) ->
    Worker_state2 = Worker_state#worker_state{
                      error_status = ack_message_queue,
                      error_message = Worker_state#worker_state.error_status},
    snake_utility:log_job_status(Worker_state2),
    amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Worker_state2#worker_state.queue_message_tag}).

spawn_worker(Worker_state, Module, Fun) when is_record(Worker_state, worker_state) ->
    Pid = spawn_link(fun() -> apply(Module, Fun, [Worker_state]) end),
    case is_process_alive(Pid) of
        true -> Pid;
        _ -> none
    end.

build_mq_connection(HostName, QueueName) ->
    {ok, Connection} = amqp_connection:start(#amqp_params_network{host = HostName}),
    {Ret, Channel} = amqp_connection:open_channel(Connection),
    case Ret of
        error ->
            ok = amqp_connection:close(Connection),
            error(fail_build_connection);
        ok ->
            Result = amqp_channel:call(Channel,
                                       #'queue.declare'{queue = list_to_binary(QueueName),
                                                        durable = true}),
            case Result of
                #'queue.declare_ok'{queue = _Q} -> ok;
                _ ->
                    ok = amqp_channel:close(Channel),
                    ok = amqp_connection:close(Connection)
            end,
            {Connection, Channel}
    end.

close_mq_connection(Connection, Channel) ->
    ok = amqp_channel:close(Channel),
    ok = amqp_connection:close(Connection),
    ok.

send_message_to_queue(Channel, Queue_name, Task_message) ->
    Bin = term_to_binary(Task_message),
    ok = amqp_channel:cast(Channel,
                           #'basic.publish'{
                             exchange = <<"">>,
                             routing_key = list_to_binary(Queue_name)},
                           #amqp_msg{props = #'P_basic'{delivery_mode = 2},
                                     payload = Bin}),
    ok.

cmd(Command, Options) ->
    Default_options = [{line,4096},exit_status,use_stdio],
    Options1 = Options ++ Default_options,
    Port = open_port({spawn,Command},Options1),
    case loop_cmd(Port,"") of
        {ok,Result} ->
            {ok,Result};
        {error,_Status,Res} ->
            {error,Res}
    end.

loop_cmd(Port,Result) ->
    receive
        {Port,{exit_status,0}} ->
            {ok,Result};
        {Port,{exit_status,Status}} ->
            {error,Status,Result};
        {Port, {data,{eol,Data}}} ->
            loop_cmd(Port,Result ++ "\n" ++ Data);
        {Port, {data,{noeol,Data}}} ->
            loop_cmd(Port,Result ++ Data)
    after 10000 ->
	    error_logger:error_msg("port call timeout, Port:~p, Module:~p, Func:~p, Result:~p, Line:~p", [Port, ?MODULE, loop_cmd, Result, ?LINE]),
	    catch port_close(Port),
	    {error, 1, timeout}
    end.
%% #################################################################
%%% File : snake_utility.erl ends
