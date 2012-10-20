#!/usr/bin/env escript

-mode(compile).

main([]) ->
  {ok,Bin} = file:read_file("m.xml"),
  List = binary_to_list(Bin),
  code:add_pathz("ebin"),
  Count = 100,
  Self = self(),
  T0 = erlang:now(),
  spawn(fun() -> loop_parsexml(Bin, Count), 
    Self ! {ready, parsexml, timer:now_diff(erlang:now(),T0),process_info(self(),memory)} end),
  spawn(fun() -> loop_xmerl(List, Count), 
    Self ! {ready, xmerl, timer:now_diff(erlang:now(),T0),process_info(self(),memory)} end),
  receive
    {ready,xmerl,T1,{memory,M1}} -> io:format("   xmerl: ~p ~8.. B~n", [T1,M1])
  end,
  receive
    {ready,parsexml,T2,{memory,M2}} -> io:format("parsexml: ~p ~8.. B~n", [T2,M2])
  end,
  ok.

loop_parsexml(_Bin,0) -> ok;
loop_parsexml(Bin,Count) ->
  A = parsexml:parse(Bin),
  loop_parsexml(Bin,Count-1).

loop_xmerl(_Bin,0) -> ok;
loop_xmerl(Bin,Count) ->
  A = xmerl_scan:string(Bin),
  loop_xmerl(Bin,Count-1).
