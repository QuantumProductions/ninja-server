-module(temple).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

queue_test() ->
	T = new(),
  T1 = join(T, a),
  T2 = join(T1, b),
  T3 = join(T2, c),
  T4 = join(T3, d),
  {A, Q} = join(T4, e),
  [{a,{{undefined,undefined},0}},
  {b,{{undefined,undefined},0}},
  {c,{{undefined,undefined},0}},
  {d,{{undefined,undefined},0}}] = dict:to_list(A),
  [e] = Q.

battle_test() ->
	T = new(),
  T1 = join(T, a),
  T2 = join(T1, b),
  T3 = join(T2, c),
  T4 = join(T3, d),
  T5 = join(T4, e),
  T6 = input(T5, a, kill, b),
  T7 = input(T6, b, kill, c),
  T8 = input(T7, c, counter, b),
  T9 = input(T8, d, kill, b),
  {{Repopulated, Queue}, Slain} = fight(T9),
  [{a,{{undefined,undefined},1}},
  {c,{{undefined,undefined},0}},
  {d,{{undefined,undefined},1}},
  {e,{{undefined,undefined},0}}] = dict:to_list(Repopulated),
  Slain = [b],
  Queue = [].

new() ->
  {arena:new(), []}. % empty queue.

joinable(Arena) ->
  dict:size(Arena) < 4.

join({Arena, Queue}, Newcomer) ->
  case joinable(Arena) of
  	false -> {Arena, lists:append(Queue, [Newcomer])};
  	true -> {arena:join(Arena, Newcomer), Queue}
  end.

input({A, Q}, Ninja, Action, Target) ->
  {arena:assignInput(A, Ninja, Action, Target), Q}.

fight({A, Q}) ->
  {Survivors, Slain} = filterSurvivors(dict:to_list(arena:fight(A))),
  SurvivorsDict = dict:from_list(Survivors),
  {RepopulatedArena, UsedQueue} = repopulate({SurvivorsDict, Q}),
  {{RepopulatedArena, UsedQueue}, Slain}.
  %Slain are broadcast
  %Survivors are fed into next Temple

repopulate({A, []}) ->
  {A, []};
repopulate({A, [H | T]}) ->
  case joinable(A) of
  	true -> repopulate({arena:join(A, H), T});
  	false -> {A, [H | T]}
  end.

filterSurvivors(Survivors) ->
  filterSurvivors(Survivors, [], []).
filterSurvivors([], Filtered, Slain) ->
  {Filtered, Slain};
filterSurvivors([{Ninja,{{_,dead}, _Score}} | T], Filtered, Slain) ->
  filterSurvivors(T, Filtered, lists:append(Slain, [Ninja]));
filterSurvivors([{Ninja,{{_,_Status}, Score}} | T], Filtered, Slain) ->
  filterSurvivors(T, lists:append(Filtered, 
  	[{Ninja,{{undefined, undefined}, Score}}]), Slain).


