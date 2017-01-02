-module(guestbook).
-include_lib("eunit/include/eunit.hrl").
-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

registration_test() ->
  {ok, Guestbook} = guestbook:start_link(),
  Response = gen_server:call(Guestbook, {register, "Ninja"}),
  Response = "myauth",
  gen_server:call(Guestbook, {validate_auth, "Ninja", "myauth"}).

start_link() ->
  gen_server:start_link(?MODULE, [], []).

init([]) ->
  {ok, dict:new()}.

generateAuth() ->
  "myauth".

valid(Guestbook, Name, Auth) ->
  string:equal(dict:fetch(Name, Guestbook), Auth).

handle_call({register, Name}, _From, State) ->
  Auth = generateAuth(),
  Guestbook = dict:store(Name, Auth, State),
  {reply, Auth, Guestbook};
handle_call({validate_auth, Name, Auth}, _From, State) ->
  {reply, valid(State, Name, Auth), State};
handle_call(terminate, _From, Temple) ->
  {stop, normal, ok, Temple};
handle_call(_, _, _) ->
  {reply, ignored, ignored}.

terminate(normal, Temple) ->
    io:format("Guestbook flooded with ink.~p~n", [Temple]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}. 

handle_cast(_, Temple) ->
    {noreply, Temple}.

handle_info(Msg, Temple) ->
  io:format("Unexpected message: ~p~n",[Msg]),
  {noreply, Temple }.