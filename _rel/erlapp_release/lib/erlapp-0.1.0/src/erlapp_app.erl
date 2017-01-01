-module(erlapp_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
        {"/action", action_handler, []},
        {"/join", hello_handler, []}]}
    ]),
    {ok, _} = cowboy:start_clear(my_http_listener, 100,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    {ok, Pid} = gate:start_link(),
    register(gate, Pid),
    {ok, Guestbook} = guestbook:start_link(),
    register(guestbook, Guestbook),
    gate:action(Pid, {fight}),
    erlapp_sup:start_link().

stop(_State) ->
	ok.

