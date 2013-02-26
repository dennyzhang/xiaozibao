-module(debug_loader).
-export([c/1, changed/0, restore_all/0, restore/1, module_to_file/2]).

changed() ->
    ets:foldl(fun({Mod, _, _}, _)->
            erlang:display(Mod)
        end, [], ets()),
    ok.

restore_all() ->
    ets:foldl(fun({Mod, Bin, File}, _)->
            restore_bin(Mod, Bin,File)
        end, [], ets()).

restore(Mod) ->
    case ets:lookup(ets(), Mod) of
        [] -> {error, nochanged};
        [{Mod,Bin,File}|_] -> restore_bin(Mod,Bin,File)
    end.

restore_bin(Mod,Binary,File)->
    true = code:soft_purge(Mod),
    {module, Mod} = code:load_binary(Mod, File, Binary).

ets() ->
    case ets:info(?MODULE, name) of
        undefined ->
            ets:new(?MODULE, [named_table, duplicate_bag, public]);
        ?MODULE -> ok
    end,
    ?MODULE.

c(File) when is_list(File)->
    {ok, Mod} = get_module_by_file(File),

    Opts = case application:get_application(Mod) of
	{ok, App} -> [{i,code:lib_dir(App, include)}];
	_ -> []
    end,

    {ok, Mod, Binary} = compile:file(File,
            [verbose,report_errors,
            report_warnings,binary,
            {i, filename:dirname(File)} ]++Opts),
    load(Mod, File, Binary).

load(Mod, File, Binary)->
    try reloader:stop()  catch _:_ -> ok end,
    case ets:lookup(ets(), Mod) of
        [] ->
            {Mod, Bin, OldFile} = code:get_object_code(Mod),
            true = ets:insert(ets(), {Mod, Bin, OldFile});
        _ -> ok
    end,
    code:purge(Mod),
    code:load_binary(Mod, File, Binary).

get_module_by_file(File)->
    {ok, Epp} = epp:open(File,[]),
    get_module_by_epp(Epp).

get_module_by_epp(Epp)->
    case epp:parse_erl_form(Epp) of
        {ok,{attribute,_,module,Mod}} -> {ok,Mod};
        {ok,_} -> get_module_by_epp(Epp);
        Other -> Other
    end.

module_to_file(Mod, Filename) ->
    {ok, Fd} = file:open(Filename,[write,read,binary,delayed_write]),
    {ok,{_,[{abstract_code,{_,AC}}]}} = beam_lib:chunks(code:which(Mod),[abstract_code]),
    file:pwrite(Fd, 0, [erl_prettypr:format(erl_syntax:form_list(AC))]).
