%%%-------------------------------------------------------------------
%%% @copyright 2013
%%% File : snake_header.hrl
%%% Author : filebat <markfilebat@126.com>
%%% Description :
%%% -- Common header for snake services: time fields, structure of task entries
%%% Created : <2011-09-05>
%%% Updated: Time-stamp: <2013-02-26 15:24:53>
%%%-------------------------------------------------------------------
%% --8<-------------------------- §message format§ ------------------------>8--
-record(thrift_request_state, {thrift_pid, request_data, response_data, error_status, error_message}).
-record(task_message, {siteid, snakeid, expandid, command}).
-record(task_entry, {siteid_snakeid_expandid, timestamp, command}).
-record(task_raw_entry, {siteid_snakeid, label, entry}).
-record(task_status, {siteid_snakeid, command, finish_time, error_status, error_message}).
%%-record(task_entry, {<<minute:6/binary>>, <<hour:4/binary>>, <<day:5/binary>>, <<month:4/binary>>, <<dayofweek:3/binary>>, <<command:20/binary>>}).
%% --8<-------------------------- §task status§ ------------------------>8--
-define(TASK_RET_OK, "ok").
-define(TASK_RET_FAILED, "failed").
-define(TASK_RET_TIMEOUT, "timeout").
%% --8<-------------------------- §snake time§ ------------------------>8--
%% valid value range of each time field
-define(MINUTE_RANGE, 60).
-define(HOUR_RANGE, 24).
-define(DAY_RANGE, 31).
-define(MONTH_RANGE, 12).
-define(DAYOFWEEK_RANGE, 7).
%% length of each time field
-define(MINUTE_FIELD_LENGTH, 6).
-define(HOUR_FIELD_LENGTH, 5).
-define(DAY_FIELD_LENGTH, 5).
-define(MONTH_FIELD_LENGTH, 4).
-define(DAYOFWEEK_FIELD_LENGTH, 4).
%% wild match for certain field of snake timestamp
-define(ANY_DAYOFWEEK, (1 bsl ?DAYOFWEEK_FIELD_LENGTH - 1)).
-define(ANY_MONTH, (1 bsl ?MONTH_FIELD_LENGTH - 1)).
-define(ANY_DAY, (1 bsl ?DAY_FIELD_LENGTH - 1)).
-define(ANY_HOUR, (1 bsl ?HOUR_FIELD_LENGTH - 1)).
-define(ANY_MINUTE, (1 bsl ?MINUTE_FIELD_LENGTH - 1)).

%% Mask to keep certain field of snake timestamp, with others excluded
-define(DAYOFWEEK_MASK, (1 bsl ?DAYOFWEEK_FIELD_LENGTH - 1)).
-define(MONTH_MASK, ((1 bsl ?MONTH_FIELD_LENGTH - 1)
                     bsl ?DAYOFWEEK_FIELD_LENGTH)).
-define(DAY_MASK, (?ANY_DAY bsl (?MONTH_FIELD_LENGTH + ?DAYOFWEEK_FIELD_LENGTH))).
-define(HOUR_MASK, (?ANY_HOUR bsl (?DAY_FIELD_LENGTH +
                                   ?MONTH_FIELD_LENGTH + ?DAYOFWEEK_FIELD_LENGTH))).
-define(MINUTE_MASK, (?ANY_MINUTE bsl (?HOUR_FIELD_LENGTH + ?DAY_FIELD_LENGTH +
                                       ?MONTH_FIELD_LENGTH + ?DAYOFWEEK_FIELD_LENGTH))).
%% Function
-define(SPLIT_TIMESTAMP(Timestamp),
        {(((Timestamp) band ?MINUTE_MASK) bsr (?HOUR_FIELD_LENGTH + ?DAY_FIELD_LENGTH +
                                            ?MONTH_FIELD_LENGTH + ?DAYOFWEEK_FIELD_LENGTH)),
         (((Timestamp) band ?HOUR_MASK) bsr (?DAY_FIELD_LENGTH + ?MONTH_FIELD_LENGTH + ?DAYOFWEEK_FIELD_LENGTH)),
         (((Timestamp) band ?DAY_MASK) bsr (?MONTH_FIELD_LENGTH + ?DAYOFWEEK_FIELD_LENGTH)),
         (((Timestamp) band ?MONTH_MASK) bsr ?DAYOFWEEK_FIELD_LENGTH),
         (((Timestamp) band ?DAYOFWEEK_MASK))}).
%% --8<-------------------------- §task_entry§ ------------------------>8--
%% assume site count is less then 268,435,456
-define(SITE_ID_LENGTH, 28).
%% assume snake count of one site is less than 65536
-define(SNAKE_ID_LENGTH, 16).
%% assume one snake can expand to less than 4096 tasks
-define(EXPAND_ID_LENGTH, 12).
%% Mask to keep certain field of siteid_snakeid_expandid, with others excluded
-define(SITE_ID_MASK, ((1 bsl ?SITE_ID_LENGTH - 1) bsl (?SNAKE_ID_LENGTH + ?EXPAND_ID_LENGTH))).
-define(SNAKE_ID_MASK, ((1 bsl ?SNAKE_ID_LENGTH - 1) bsl ?EXPAND_ID_LENGTH)).
-define(EXPAND_ID_MASK, (1 bsl ?EXPAND_ID_LENGTH - 1)).
%% retrieve certain field from siteid_snakeid_expandid
-define(OBTAIN_SITE_ID(Siteid_snakeid_expandid), ((Siteid_snakeid_expandid) band ?SITE_ID_MASK)).
-define(OBTAIN_SNAKE_ID(Siteid_snakeid_expandid), ((Siteid_snakeid_expandid) band ?SNAKE_ID_MASK)).
-define(OBTAIN_EXPAND_ID(Siteid_snakeid_expandid), ((Siteid_snakeid_expandid) band ?EXPAND_ID_MASK)).
%% Functions
-define(SPLIT_SNAKE_ID(Siteid_snakeid_expandid),
        {((?OBTAIN_SITE_ID((Siteid_snakeid_expandid))) bsr (?SNAKE_ID_LENGTH + ?EXPAND_ID_LENGTH)),
         ((?OBTAIN_SNAKE_ID((Siteid_snakeid_expandid))) bsr ?EXPAND_ID_LENGTH),
         (?OBTAIN_EXPAND_ID((Siteid_snakeid_expandid)))}).
-define(SPLIT_SNAKE_ID2(Siteid_snakeid),
        (?SPLIT_SNAKE_ID((Siteid_snakeid) bsl ?EXPAND_ID_LENGTH))).
-define(BUILD_SITEID_SNAKEID_EXPANDID(Site_id, Snake_id, Expand_id),
        (((Site_id) bsl (?SNAKE_ID_LENGTH + ?EXPAND_ID_LENGTH)) bor ((Snake_id) bsl ?EXPAND_ID_LENGTH) bor (Expand_id))).
-define(BUILD_SITEID_SNAKEID(Site_id, Snake_id),
        (?BUILD_SITEID_SNAKEID_EXPANDID((Site_id), (Snake_id), 0) bsr ?EXPAND_ID_LENGTH)).
%% --8<-------------------------- §store snake status§ ------------------------>8--
-define(STORE_SNAKE_STATUS, "store_snake_status").
-define(GET_SNAKE_STATUS, "get_snake_status").
%% --8<-------------------------- §separator§ ------------------------>8--
%%% File : snake_header.hrl ends
