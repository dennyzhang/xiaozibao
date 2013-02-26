%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : snake_worker_thrift.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2011-09-05>
%%% Updated: Time-stamp: <2013-02-26 15:24:52>
%%%-------------------------------------------------------------------
-module(snake_worker_thrift).
-behaviour(gen_service_new).

%%-include("ecae_types.hrl").
-include_lib("snake_header.hrl").

-export([start_link/0]).

-export([getName/0, getVersion/0, sanityCheck/0]).

-compile([export_all]). %% TODO, removed later

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------
-export([init/1, handle_call/3, handle_function/2, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
start_link() ->
    {ok, Port} = application:get_env(snake_worker, thrift_listen),
    {ok, Node} = case application:get_env(snake_worker, nodename) of
                     {ok, N} when is_list(N) -> {ok, N};
                     _ -> inet:gethostname()
                 end,
    gen_service_new:start_link('snake.worker', ?MODULE, Port, [], [{node,Node}
                                                                   ,{thrift, snake_workerService_thrift}]).

%% ------------------------------------------------------------------
%% gen_server Function Definitions
%% ------------------------------------------------------------------
init(Args) ->
    {ok, Args}.

handle_function(Function, Args) when is_atom(Function), is_tuple(Args) ->
    case apply(?MODULE, Function, tuple_to_list(Args)) of
        ok -> ok;
        Reply -> {reply, Reply}
    end.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --8<-------------------------- § Thrift Service API § ------------------------>8--
%% string getName()
getName() ->
    "snake.worker".

%% string getVersion()
getVersion() ->
    "0.1.0".

%% string getCpuProfile(1: i32 profileDurationInSec)
getCpuProfile() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    ok.

%% oneway void reinitialize()
reinitialize() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    true.
%% oneway void shutdown()
shutdown() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    ok.

sanityCheck() ->
    Service_name = getName(),
    Service_name_bin = list_to_binary(Service_name),
    Port = shopex_utils:get_option_from_cfg(snake_worker, thrift_listen),
    Ip = "127.0.0.1",
    %% Simple test case
    Service_name_bin =
        ecae_thrift_client:thrift_client_call(ip_port, Ip, Port, snake_workerService_thrift, getName, []),

    <<"0.1.0">> = ecae_thrift_client:thrift_client_call(ip_port, Ip, Port, snake_workerService_thrift, getVersion, []),

    ok = testCurlworker(),

    ok = testCrontabworker(),

    ok = testPhpLoopWorker(),

    ok = testPhpJobWorker(),

    ok = testShellworker(),
    true.

notify_queue_change(Queue_name_bin, Op_type) ->
    Queue_name = binary_to_list(Queue_name_bin),
    Return_list = lists:map(fun(Node) ->
                                    Ret = rpc:call(Node, snake_worker_thrift, local_notify_queue_change, [Queue_name, Op_type]),
                                    case Ret of
                                        false ->
                                            error_logger:error_msg("[~p][~p:~p:~p] Fail to notify node:~p, Queue update. Queue_name:~n, Op_type:~p",
                                                                   [self(), calendar:now_to_local_time(now()), ?MODULE, ?LINE, Node, Queue_name, Op_type]);
                                        true -> ok
                                    end,
                                    Ret
                            end, nodes()),
    L = lists:filter(fun(X) -> X =/= true end, Return_list),
    Ret = local_notify_queue_change(Queue_name, Op_type),
    Ret and (length(L) =:= 0).

local_notify_queue_change(Queue_name, Op_type) when Op_type =:= 0 ->
    error_logger:info_msg("[~p][~p:~p:~p] add a listener for queue:~p~n",
                          [self(), calendar:now_to_local_time(now()), ?MODULE, ?LINE, Queue_name]),
    Listener_service_list = snake_worker_sup:get_queue_childspec([Queue_name]),
    case length(Listener_service_list) of
        0 -> true;
        1 -> [Listener_service] = Listener_service_list,
             case supervisor:start_child(snake_worker_sup, Listener_service) of
                 {error,{already_started,_Pid}} -> true;
                 {ok,_Pid} -> true;
                 _ -> false
             end
    end;
local_notify_queue_change(Queue_name, Op_type) when Op_type =:= 1 ->
    error_logger:info_msg("[~p][~p:~p:~p] remove the listener for queue:~p~n",
                          [self(), calendar:now_to_local_time(now()), ?MODULE, ?LINE, Queue_name]),
    Listener_service_list = snake_worker_sup:get_queue_childspec([Queue_name]),
    case length(Listener_service_list) of
        0 -> true;
        1 -> [{Id, {_Module, start_link, [_Args]}, permanent, 50000, worker, [_Module]}] = Listener_service_list,
             case supervisor:terminate_child(snake_worker_sup, Id) of
                 ok -> true;
                 {error,not_found} -> true;
                 _ -> fase
             end,
             case supervisor:delete_child(snake_worker_sup, Id) of
                 ok -> true;
                 {error,not_found} -> true;
                 _ -> fase
             end
    end.

%% map<string, string> getOptions()
getOptions() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    ok.
%% --8<-------------------------- § not exported thrift API of thrif303 § ------------------------>8--
resetCounter() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    ok.

incrementCounter() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    ok.

getLimitedReflection() ->
    error_logger:info_msg("[~p:~p:~p] Warning: function not supported~n",[self(), ?MODULE, ?LINE]),
    ok.
%% --8<-------------------------- §utilities§ ------------------------>8--
testCurlworker() ->
    Timeout = 3000,
    {ok, Request_id3} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token&queue=snake_worker-curl#10#host_domain-1#1&data=13367187642343599991234;9999;http://www.shopex.cn/index.html;stub_arg"},
                                      [], [{sync, false}]),
    receive
        {http, {Request_id3, {{_, 200, _}, _, _}}} ->
            ok;
        Msg3 ->
            error(sanity_fail_test3)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test3_timeout)
    end,

    %% fault injection for snake
    {ok, Request_id4} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token_fake&queue=snake_worker-curl#10#host_domain-1#1&data=13367187642343599991235;9999;http://127.a.0.1;stubarg"},
                                      [], [{sync, false}]),

    receive
        {http, {Request_id4, {{_, 400, _}, _, _}}} ->
            ok;
        Msg4 ->
            error_logger:error_msg("[~p:~p:~p] sanityCheck fail. Reason:~p~n",[self(), ?MODULE, ?LINE, Msg4]),
            error(sanity_fail_test4)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test4_timeout)
    end,

    %% fault injection for snake for wrong site_id
    {ok, Request_id5} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token_fake&queue=snake_worker-curl#10#host_domain-1#1&data=13367187642343599891235;a9999;http://127.a.0.1;stubarg"},
                                      [], [{sync, false}]),

    receive
        {http, {Request_id5, {{_, 400, _}, _, _}}} ->
            ok;
        Msg65 ->
            error_logger:error_msg("[~p:~p:~p] sanityCheck fail. Reason:~p~n",[self(), ?MODULE, ?LINE, Msg65]),
            error(sanity_fail_test5)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test5_timeout)
    end,
    ok.

testCrontabworker() ->
    Timeout = 3000,
    {ok, Request_id3} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token&queue=snake_worker-crontab#10#host_domain-1#1&data=13367187642343599993234;9999;http://www.shopex.cn/index.html;stub_arg"},
                                      [], [{sync, false}]),
    receive
        {http, {Request_id3, {{_, 200, _}, _, _}}} ->
            ok;
        Msg3 ->
            error_logger:error_msg("[~p:~p:~p] here:~p~n",[self(), ?MODULE, ?LINE, Msg3]),
            error(sanity_fail_test3)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test3_timeout)
    end,

    %% fault injection for snake
    {ok, Request_id4} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token_fake&queue=snake_worker-crontab#10#host_domain-1#1&data=13367187642343599891235;9999;http://127.a.0.1;stubarg"},
                                      [], [{sync, false}]),

    receive
        {http, {Request_id4, {{_, 400, _}, _, _}}} ->
            ok;
        Msg4 ->
            error_logger:error_msg("[~p:~p:~p] sanityCheck fail. Reason:~p~n",[self(), ?MODULE, ?LINE, Msg4]),
            error(sanity_fail_test4)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test4_timeout)
    end,
    ok.

testPhpLoopWorker() ->
    Timeout = 3000,
    {ok, Request_id} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                            [], "application/x-www-form-urlencoded",
                                            "token=snake_token&queue=snake_worker-php_loop#10#host_domain-1#1&data=13367187642343699991236;9999;php_loop_sample.php;stubarg"},
                                     [], [{sync, false}]),
    receive
        {http, {Request_id, {{_, 200, _}, _, _}}} ->
            ok;
        Msg1 ->
            error_logger:error_msg("[~p:~p:~p] here:~p~n",[self(), ?MODULE, ?LINE, Msg1]),
            error(sanity_fail_php_loop_1)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_php_loop_1_timeout)
    end,

    %% test without argument
    {ok, Request_id2} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token&queue=snake_worker-php_loop#10#host_domain-1#1&data=13367187642343699991237;9999;php_loop_sample.php;"},
                                      [], [{sync, false}]),
    receive
        {http, {Request_id2, {{_, 200, _}, _, _}}} ->
            ok;
        Msg2 ->
            error_logger:error_msg("[~p:~p:~p] here:~p~n",[self(), ?MODULE, ?LINE, Msg2]),
            error(sanity_fail_php_loop_2)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_php_loop_2_timeout)
    end,

    %% fault injection for snake
    {ok, Request_id3} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token_fake&queue=snake_worker-php_loop#10#host_domain-1#1&data=13367187642343699991238;9999;php_loop_sample.php;stubarg"},
                                      [], [{sync, false}]),

    receive
        {http, {Request_id3, {{_, 400, _}, _, _}}} ->
            ok;
        Msg3 ->
            error_logger:error_msg("[~p:~p:~p] sanityCheck fail. Reason:~p~n",[self(), ?MODULE, ?LINE, Msg3]),
            error(sanity_fail_php_loop_3)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_php_loop_3_timeout)
    end,
    ok.

testPhpJobWorker() ->
    Timeout = 3000,
    {ok, Request_id} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                            [], "application/x-www-form-urlencoded",
                                            "token=snake_token&queue=snake_worker-php_job#10#host_domain-1#1&data=13367187642343799992235;9999;php_job_sample.php;stubarg"},
                                     [], [{sync, false}]),
    receive
        {http, {Request_id, {{_, 200, _}, _, _}}} ->
            ok;
        Msg1 ->
            error_logger:error_msg("[~p:~p:~p] here:~p~n",[self(), ?MODULE, ?LINE, Msg1]),
            error(sanity_fail_php_job_1)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_php_job_1_timeout)
    end,

    %% test without argument
    {ok, Request_id2} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token&queue=snake_worker-php_job#10#host_domain-1#1&data=13367187642343799992237;9999;php_job_sample.php;"},
                                      [], [{sync, false}]),
    receive
        {http, {Request_id2, {{_, 200, _}, _, _}}} ->
            ok;
        Msg2 ->
            error_logger:error_msg("[~p:~p:~p] here:~p~n",[self(), ?MODULE, ?LINE, Msg2]),
            error(sanity_fail_php_job_2)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_php_job_2_timeout)
    end,

    %% fault injection for snake
    {ok, Request_id3} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token_fake&queue=snake_worker-php_job#10#host_domain-1#1&data=13367187642343799991237;9999;php_job_sample.php;stubarg"},
                                      [], [{sync, false}]),

    receive
        {http, {Request_id3, {{_, 400, _}, _, _}}} ->
            ok;
        Msg3 ->
            error_logger:error_msg("[~p:~p:~p] sanityCheck fail. Reason:~p~n",[self(), ?MODULE, ?LINE, Msg3]),
            error(sanity_fail_php_job_3)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_php_job_3_timeout)
    end,
    ok.

testShellworker() ->
    Timeout = 3000,
    {ok, Request_id3} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=snake_token&queue=snake_worker-shell#10#host_domain-1#1&data=13367187642343899991238;9999;cat /etc/hosts;"},
                                      [], [{sync, false}]),
    receive
        {http, {Request_id3, {{_, 200, _}, _, _}}} ->
            ok;
        Msg3 ->
            error_logger:error_msg("[~p:~p:~p] here:~p~n",[self(), ?MODULE, ?LINE, Msg3]),
            error(sanity_fail_test3)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test3_timeout)
    end,

    %% fault injection for snake
    {ok, Request_id4} = httpc:request(post, {"http://127.0.0.1:9110/snake",
                                             [], "application/x-www-form-urlencoded",
                                             "token=shell_token&queue=snake_worker-shell#10#host_domain-1#1&data=13367187642343899991239;9999ls /tmp/abadadfafdaf"},
                                      [], [{sync, false}]),

    receive
        {http, {Request_id4, {{_, 400, _}, _, _}}} ->
            ok;
        Msg4 ->
            error_logger:error_msg("[~p:~p:~p] sanityCheck fail. Reason:~p~n",[self(), ?MODULE, ?LINE, Msg4]),
            error(sanity_fail_test4)
    after Timeout ->
            error_logger:error_msg(" Timeout, after ~p milseconds~n", [Timeout]),
            error(sanity_fail_test4_timeout)
    end,
    ok.
%%% File : snake_worker_thrift.erl ends
