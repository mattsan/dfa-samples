% $ erlc dfa.erl
% $ erl -noshell -s dfa start -s init stop
% a => false
% baa => false
% baba => true

-module(dfa).
-export([start/0]).

appliesTo({rule, State0, Character0, _}, State1, Character1) ->
  (State0 == State1) and (Character0 == Character1).

follow({rule, _, _, NextState}) ->
  NextState.

ruleFor([Rule|Rules], State, Character) ->
  case appliesTo(Rule, State, Character) of
    true -> Rule;
    false -> ruleFor(Rules, State, Character)
  end.

nextState(Rules, State, Character) ->
  Rule = ruleFor(Rules, State, Character),
  follow(Rule).

isAccepting({dfa, State, AcceptStates, _}) ->
  lists:member(State, AcceptStates).

readCharacter(DFA, Character) ->
  {dfa, State0, AcceptStates, Rules} = DFA,
  State1 = nextState(Rules, State0, Character),
  {dfa, State1, AcceptStates, Rules}.

readString(DFA, "") ->
  DFA;
readString(DFA, [C|CS]) ->
  DFA2 = readCharacter(DFA, C),
  readString(DFA2, CS).

isAccepts(DFA, String) ->
  DFA1 = readString(DFA, String),
  isAccepting(DFA1).

rules() -> [
  {rule, 1, $a, 2}, {rule, 1, $b, 1},
  {rule, 2, $a, 2}, {rule, 2, $b, 3},
  {rule, 3, $a, 3}, {rule, 3, $b, 3}
].

test(DFA, String) ->
  io:format("~s => ~p~n", [String, isAccepts(DFA, String)]).

start() ->
  Rules = rules(),
  DFA = {dfa, 1, [3], Rules},
  test(DFA, "a"),
  test(DFA, "baa"),
  test(DFA, "baba").
