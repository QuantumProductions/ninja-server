-module(arena).
-include_lib("eunit/include/eunit.hrl").
-compile(export_all).

join_test() ->
  Arena = join(a),
  Arena11 = join(Arena, a),
  [{a,{{_,_}, 0}}, {b,{{_,_}, 0}}] = dict:to_list(join(Arena11, b)).

assign_test() ->
  Arena = join(a),
  [{a, {{kill, b}, 0}}] = dict:to_list(assignInput(Arena, a, kill, b)).

score_test() ->
  Arena = join(join(join(a), b), c),
  Arena2 = assignInput(Arena, a, kill, b),
  Arena3 = assignInput(Arena2, b, kill, c),
  Arena4 = assignInput(Arena3, c, counter, b),
  [{a,{{undefined,slayer},1}},
  {b,{{undefined,dead},0}},
  {c,{{undefined,survivor},0}}] = dict:to_list(fight(Arena4)).

new() ->
  dict:new().

join(Newcomer) ->
  join(dict:new(), Newcomer).
join(Arena, Newcomer) ->
  case existingCombatant(Arena, Newcomer) of
  	true -> Arena;
  	false -> dict:store(Newcomer, {{undefined, undefined}, 0}, Arena)
  end.

assignInput(Arena, Ninja, Action, Target) ->
  case existingCombatant(Arena, Ninja) of
  	false -> Arena;
  	true -> {{_, _}, Score} = dict:fetch(Ninja, Arena),
            dict:store(Ninja, {{Action, Target}, Score}, Arena)
  end.

existingCombatant(Arena, Ninja) ->
  dict:is_key(Ninja, Arena).

score([], Ninjas) ->
  Ninjas;
score([{Name, Result} | T], Ninjas) ->
  {{_, _}, ExistingPoints} = dict:fetch(Name, Ninjas),
  score(T, 
    dict:store(Name, {{undefined, Result}, points(Result) + ExistingPoints }, Ninjas)).

points(slayer) ->
  1;
points(_) ->
  0.

fight(Arena) ->
  fight(dict:to_list(Arena), [], Arena).
fight([], Converted, Arena) ->
  score(resolution:fight(Converted), Arena);
fight([{N, {{A, T}, _Score}} | Rest], Converted, Arena) ->
 	fight(Rest, lists:append(Converted, [{N, A, T}]), Arena).

