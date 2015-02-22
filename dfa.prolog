% swipl -s dfa.prolog -g 'main'
% a => false
% baa => false
% baba => true

rule([State, Character, NextState], State, Character, NextState).

dfa([State, AcceptState, Rules], State, AcceptState, Rules).

appliesTo(Rule, State, Character) :-
  rule(Rule, State, Character, _).

follow(Rule, NextState) :- rule(Rule, _, _, NextState).

ruleFor([Rule|_], State, Character, Rule) :- appliesTo(Rule, State, Character).
ruleFor([_|Rules], State, Character, Rule) :- ruleFor(Rules, State, Character, Rule).

nextState(Rules, State, Character, NextState) :-
  ruleFor(Rules, State, Character, Rule),
  follow(Rule, NextState).

isAccepting(DFA) :-
  dfa(DFA, State, AcceptState, _),
  member(State, AcceptState).

readCharacter(DFA0, Character, DFA1) :-
  dfa(DFA0, State0, AcceptState, Rules),
  nextState(Rules, State0, Character, State1),
  dfa(DFA1, State1, AcceptState, Rules).

readString(DFA, "", DFA).
readString(DFA0, [C|CS], DFA1) :-
  readCharacter(DFA0, C, DFA2),
  readString(DFA2, CS, DFA1).

isAccepts(DFA, String, true) :-
  readString(DFA, String, DFA1),
  isAccepting(DFA1).
isAccepts(_, _, false).

rules(Rules) :- Rules = [ [1, 0'a, 2], [1, 0'b, 1],
                          [2, 0'a, 2], [2, 0'b, 3],
                          [3, 0'a, 3], [3, 0'b, 3] ].

test(DFA, String) :-
  isAccepts(DFA, String, Result),
  format("~s => ~s~n", [String, Result]).

main :-
  rules(Rules),
  dfa(DFA, 1, [3], Rules),
  test(DFA, "a"),
  test(DFA, "baa"),
  test(DFA, "baba"),
  halt.
