-module(resolution).
-include_lib("eunit/include/eunit.hrl").
-export([fight/1]).

counter_test() ->
  CounterNinjas = [{a, counter, b}, {b, kill, a}],
  [{a, immune}, {b, dead}] = fight(CounterNinjas).

kill_test() ->
  KilledNinjas = [{a, counter, c}, {b, kill, a}],
  [{a, dead}, {b, slayer}] = fight(KilledNinjas),

  KilledNinjas2 = [{a, kill, b}, {b, kill, c}, {c, kill, b}],
  [{a, slayer}, {b, dead}, {c, dead}] = fight(KilledNinjas2).

complex_counter_kill_test() ->
  ComplexNinjas = [{a, counter, b}, {b, counter, c}, {c, kill, a}, {d, kill, b}],
  [{a, dead}, {b, dead}, {c, slayer}, {d, slayer}] = fight(ComplexNinjas),

  ComplexNinjas2 = [{a, kill, c}, {b, kill, c}, {c, counter, a}, {d, kill, a}],
  [{a, dead}, {b, dead}, {c, survivor}, {d, slayer}] = fight(ComplexNinjas2),

  ComplexNinjas3 = [{a, kill, d}, {b, kill, c}, {c, counter, a}, {d, kill, a}],
  [{a, dead}, {b, slayer}, {c, dead}, {d, dead}] = fight(ComplexNinjas3),

  TripleCounter = [{a, kill, c}, {b, kill, c}, {c, counter, d}, {d, kill, c}],
  [{a, dead}, {b, dead}, {c, survivor}, {d, dead}] = fight(TripleCounter),

  ComplexNinjas4 = [{a, kill, c}, {b, kill, c}, {c, counter, e}, {d, kill, b}, {e, kill, c}],
  [{a, dead}, {b, dead}, {c, survivor}, {d, slayer}, {e, dead}] = fight(ComplexNinjas4).

fight(Ninjas) ->
  fight(Ninjas, Ninjas, []).
fight(_, [], ResolvedNinjas) ->
  fight2(ResolvedNinjas);
fight(AllNinjas, [A | Rest], ResolvedNinjas) ->
  fight(AllNinjas, Rest, lists:append(ResolvedNinjas, [{A, resolution(A, AllNinjas)}])).

fight2(Ninjas) ->
  fight2(Ninjas, Ninjas, []).
fight2(_Ninjas, [], ResolvedNinjas) ->
  fight3(ResolvedNinjas);
fight2(AllNinjas, [{{Name, Action, Target}, Resolution} | Rest], ResolvedNinjas) ->
  fight2(AllNinjas, Rest, 
  	lists:append(ResolvedNinjas, [{{Name, Action, Target}, 
  		resolution({{Name, Action, Target}, Resolution}, AllNinjas)}])).

fight3(Ninjas) ->
  fight3(Ninjas, []).
fight3([], ResolvedNinjas) ->
  ResolvedNinjas;
fight3([{{Name, _, _}, Result} | Rest], ResolvedNinjas) ->
  fight3(Rest, lists:append(ResolvedNinjas, [{Name, Result}])).

resolution(_A, []) ->
  unresolved;
resolution(A, [First | Rest]) ->
  case resolution(A, First) of
  	unresolved -> resolution(A, Rest);
  	Result -> Result
  end;

% Ninja, Action, Target
resolution({A, _, _}, {A, _, _}) ->
  unresolved;
resolution({A, counter, B}, {B, kill, A}) ->
  immune;
resolution({{_, _, _}, dead}, _) ->
  dead;
resolution({_,_,_}, {_,_,_}) ->
  unresolved;
resolution({{_A, kill, _B}, unresolved}, {{_B, counter, _}, immune}) ->
  dead;
resolution({{A, _, _}, Status}, {{A, _, _}, Status}) ->
  Status;
resolution({{A, _, _}, unresolved}, {{_B, kill, A}, _}) ->
  dead;
resolution({{_A, kill, B}, _}, {{B, _, _}, _}) ->
  slayer;
resolution({{_A, counter, _B}, immune}, _) ->
  survivor;
resolution({{_,_,_}, _}, {{_,_,_}, _}) ->
  unresolved.
