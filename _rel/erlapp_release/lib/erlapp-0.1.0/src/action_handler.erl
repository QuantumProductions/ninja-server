-module(action_handler).
-export([init/2]).

valid(start, Gate, Name, Auth, Action, Target) ->
  case gate:action(Gate, {ninja_fighting, Name}) of
    true -> valid(auth, Gate, Name, Auth, Action, Target);
    false -> {error, player_not_fighting}
  end;
valid(auth, Gate, Name, Auth, Action, Target) ->
  case gate:action(Gate, {validate_auth, Name, Auth}) of
    true -> valid(action, Gate, Action, Target);
    false -> {error, invalid_authorization_token}
  end.
valid(action, Gate, Action, Target) ->
  case (kill =:= Action) or (counter =:= Action) of
    true -> valid(target, Gate, Target);
    false -> {error, unsupported_action}
  end.
valid(target, Gate, Target) ->
  case gate:action(Gate, {ninja_fighting, Target}) of
    true -> {ok, valid};
    false -> {error, target_not_fighting}
  end.

init(Req0, Opts) ->
  Gate = whereis(gate),

  #{name := Name} = cowboy_req:match_qs([{name, [], undefined}], Req0),
  #{action := Action} = cowboy_req:match_qs([{action, [], undefined}], Req0),
  #{target := Target} = cowboy_req:match_qs([{target, [], undefined}], Req0),
  #{auth := Auth} = cowboy_req:match_qs([{auth, [], undefined}], Req0),
  AuthString = binary_to_list(Auth),
  NameString = binary_to_list(Name),
  ActionAtom = list_to_atom(binary_to_list(Action)),
  TargetName = binary_to_list(Target),

  case valid(start, Gate, NameString, ActionAtom, TargetName, AuthString) of
    {ok, valid} -> 
      {ActedGate, _} = gate:action(Gate, {input, {NameString, ActionAtom, TargetName}}),
      Response = io_lib:format("~p",[ActedGate]),
      Reply = cowboy_req:reply(200, #{
              <<"content-type">> => <<"text/plain">>
      }, Response, Req0),
      {ok, Reply, Opts};
    {error, Error} ->
      Reply = errorReply(Error, Req0),
      {ok, Reply, Opts}
  end.        

errorReply(player_not_fighting, Req) ->
  errorReply("You have not yet entered the Arena.", Req);
errorReply(invalid_authorization_token, Req) ->
  errorReply("Invalid authorization token.", Req);
errorReply(unsupported_action, Req) ->
  errorReply("Invalid action.", Req);
errorReply(target_not_fighting, Req) ->
  errorReply("Your target has not yet entered the Arena.", Req);
errorReply(Error, Req) ->
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"text/plain">>
  }, Error, Req).