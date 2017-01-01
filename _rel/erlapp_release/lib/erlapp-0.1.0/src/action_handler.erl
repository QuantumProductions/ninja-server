-module(action_handler).
-export([init/2]).

validAuth(Name, Auth) ->
  Gate = whereis(gate),
  gate:action(Gate, {validate_auth, Name, Auth}).

validRequest(Name, Action, Target, Auth) ->
  validName(Name) and validAction(Action) and validName(Target) and 
  validAuth(Name, Auth). 

validName(Name) ->
  Gate = whereis(gate),
  gate:action(Gate, {ninja_fighting, Name}).

validAction(Action) ->
  (kill =:= Action) or (counter =:= Action).

init(Req0, Opts) ->
        Gate = whereis(gate),

        #{name := Name} = cowboy_req:match_qs([{name, [], undefined}], Req0),
        #{action := Action} = cowboy_req:match_qs([{action, [], undefined}], Req0),
        #{target := Target} = cowboy_req:match_qs([{target, [], undefined}], Req0),
        #{auth := Auth} = cowboy_req:match_qs([{auth, [], undefined}], Req0),
        NameAtom = list_to_atom(binary_to_list(Name)),
        ActionAtom = list_to_atom(binary_to_list(Action)),
        TargetAtom = list_to_atom(binary_to_list(Target)),

        case validRequest(NameAtom, ActionAtom, TargetAtom, Auth) of
        	true ->
        	  {ActedGate, _} = gate:action(Gate, {input, {NameAtom, ActionAtom, TargetAtom}}),
		        B = dict:to_list(ActedGate),
		        R= io_lib:format("~p",[B]),
		        Req = cowboy_req:reply(200, #{
		                <<"content-type">> => <<"text/plain">>
		        }, R, Req0),
		        {ok, Req, Opts};
        	false ->
        	  Req = cowboy_req:reply(200, #{
                <<"content-type">> => <<"text/plain">>
            }, <<"Invalid Request">>, Req0),
            {ok, Req, Opts}
        end.
        

