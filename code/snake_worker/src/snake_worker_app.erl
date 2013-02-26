%%%-------------------------------------------------------------------
%%% @copyright 2013 
%%% File : snake_worker_app.erl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%%
%%% Created : <2012-04-09>
%%% Updated: Time-stamp: <2013-02-26 15:23:48>
%%%-------------------------------------------------------------------
-module(snake_worker_app).

-behaviour(application).

-export([start/2, stop/1, connect_to_snake_in_same_domain/0]).

%%% ------------------------ Application callbacks -----------------------
start(_StartType, _StartArgs) ->
    Inets_ret = inets:start(),
    case Inets_ret of
        ok -> ok;
        {error,{already_started,inets}} -> ok;
        _ -> error(inets_unknown_error)
    end,
    case snake_worker_sup:start_link() of
        {ok, Pid} ->
%            All_handlers = gen_event:which_handlers(error_logger),
%            case lists:member(streamlog_logger, All_handlers) of
%                true -> ok;
%                false ->
%                    gen_event:add_handler(error_logger, streamlog_logger, ["ecae_snake"])
%            end,
            connect_to_snake_in_same_domain(),
            {ok, Pid};
        Other ->
            {error, Other}
    end.

stop(_State) ->
%    gen_event:delete_handler(error_logger, streamlog_logger, []),
    ok.

connect_to_snake_in_same_domain() ->
    L = snake_utility:get_snake_servers_in_same_domain(),
    lists:map(fun(X) ->
                      Node = "snake_worker@"++X,
                      case net_adm:ping(list_to_atom(Node)) of
                          pong -> true;
                          _ ->
                              error_logger:error_msg("[~p][~p:~p:~p] Fail to connect with:~p~n",
                                                     [self(), calendar:now_to_local_time(now()), ?MODULE, ?LINE, Node])
                      end
              end, L),
    ok.
%%% ------------------------ Gen_server callbacks -----------------------

%%% File : snake_worker_app.erl ends
