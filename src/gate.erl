-module(gate).
-behaviour(gen_server).

-define(INTERVAL, 3000).

-export([start_link/0, action/2, ninjaFighting/2, resolve/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start_link() ->
  {ok, Pid} = gen_server:start_link(?MODULE, [], []),
  {ok, _Tref} = timer:apply_after(10000, ?MODULE, resolve, [Pid]),
  {ok, Pid}.

resolve(Pid) ->
  {ok, _Tref} = timer:apply_after(10000, ?MODULE, resolve, [Pid]),
  action(Pid, {fight}).

action(Pid, Action) ->
  gen_server:call(Pid, Action).

init([]) -> 
  {ok, temple:new()}.

ninjaFighting({A, _Q}, Name) ->
  arena:existingCombatant(A, Name).

publicArena([], Public) ->
  Public;
publicArena([{Name, {{_,_}, Score}} | T ], Public) ->
  publicArena(T, lists:append(Public, [{Name, Score}])).
publicArena(A) ->
  publicArena(A, []).

handle_call({ninja_fighting, Name}, _From, Temple) ->
  {reply, ninjaFighting(Temple, Name), Temple};
handle_call({join, Name}, _From, {A, Q}) ->
  
  Existing = arena:existingCombatant(A, Name),
  case Existing of
    true ->
      {reply, {A, Q}, {A, Q}};
    false ->
      GuestAuth = gen_server:call(guestbook, {register, Name}),
      {A2, Q2} = temple:join({A, Q}, Name),
      {reply, {publicArena(dict:to_list(A2)), GuestAuth}, {A2, Q2}}
  end;
handle_call({input, {Name, Action, Target}}, _From, Temple) ->
  NewTemple = temple:input(Temple, Name, Action, Target),
  {reply, NewTemple, NewTemple};
handle_call({fight}, _From, Temple) ->
  {{RepopulatedArena, UsedQueue}, _Slain} = temple:fight(Temple),
  % broadcast slain
  NewTemple = {RepopulatedArena, UsedQueue},
  {reply, NewTemple, NewTemple};
handle_call({validate_auth, Name, Auth}, _From, Temple) ->
  Valid = gen_server:call(guestbook, {validate_auth, Name, Auth}),
  {reply, Valid, Temple};
handle_call(terminate, _From, Temple) ->
  {stop, normal, ok, Temple};
handle_call(_, _, _) ->
  {ignored, ignored}.

terminate(normal, Temple) ->
    io:format("Temple bathed in blood.~p~n", [Temple]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}. 

handle_cast(_, Temple) ->
    {noreply, Temple}.

handle_info(Msg, Temple) ->
  io:format("Unexpected message: ~p~n",[Msg]),
  {noreply, Temple }.