-module(hello_handler).
-export([init/2]).

init(Req0, Opts) ->
        Gate = whereis(gate),
        #{name := Name} = cowboy_req:match_qs([{name, [], undefined}], Req0),
        NameAtom = list_to_atom(binary_to_list(Name)),
        {JoinedGate, Auth} = gate:action(Gate, {join, NameAtom}),
        JoinedGate2 = lists:append(JoinedGate, {auth, Auth}),
        R= io_lib:format("~p",[JoinedGate2]),
        Req = cowboy_req:reply(200, #{
                <<"content-type">> => <<"text/plain">>
        }, R, Req0),
        {ok, Req, Opts}.