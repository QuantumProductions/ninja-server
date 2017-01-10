-module(hello_handler).
-export([init/2]).

init(Req0, Opts) ->
  Gate = whereis(gate),
  #{name := Name} = cowboy_req:match_qs([{name, [], undefined}], Req0),
  {JoinedGate, Auth} = gate:action(Gate, {join, binary_to_list(Name)}),
  JoinedGate2 = lists:append(JoinedGate, [{auth, Auth}]),
  % TODO
  R= io_lib:format("~p",[JoinedGate2]),
  Req = cowboy_req:reply(200, #{
          <<"content-type">> => <<"text/plain">>
  }, R, Req0),
  {ok, Req, Opts}.