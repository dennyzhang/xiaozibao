%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : defined.hrl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%% -- Common header for snake services
%%% Created : <2012-04-26>
%%% Updated: Time-stamp: <2013-02-26 15:24:25>
%%%-------------------------------------------------------------------
-record(thrift_request_state, {thrift_pid, request_data, response_data, error_status, error_message}).
-record(queue_listener_state, {rabbitmq_server, queue_name, connection, channel, task_type="ecae_snake", listener_name, misc}).
-record(worker_controller_state, {controller_name, idle_workers, busy_workers, misc}).
-record(worker_state, {site_id, message_id, task_id, task_arg, task_type="ecae_snake", queue_message_tag,
                       worker_id, error_status, error_message="", listener_name, misc}).
%% --8<-------------------------- §separator§ ------------------------>8--
%%% File : defined.hrl ends
