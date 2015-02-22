// $ io dfa.io
// a => false
// baa => false
// baba => true

FARule := Object clone do(
  appiesTo := method(state, character, self state == state and self character == character)
  follow := method(self nextState)
  new := method(state, character, nextState,
    rule := FARule clone
    rule state := state
    rule character := character
    rule nextState := nextState
    rule
  )
)

DFARulebook := Object clone do(
  ruleFor := method(state, character,
    self rules detect(r, r appiesTo(state, character))
  )
  nextState := method(state, character,
    ruleFor(state, character) follow
  )
  new := method(rules,
    rulebook := DFARulebook clone
    rulebook rules := rules
    rulebook
  )
)

DFA := Object clone do(
  isAccepting := method(
    self accept_states indexOf(current_state) not not
  )
  readCharacter := method(character,
    self current_state = rulebook nextState(self current_state, character)
  )
  readString := method(string,
    string foreach(c, readCharacter(c))
  )
  new := method(current_state, accept_states, rulebook,
    dfa := DFA clone
    dfa current_state := current_state
    dfa accept_states := accept_states
    dfa rulebook := rulebook
    dfa
  )
)

DFADesign := Object clone do(
  toDFA := method(
    DFA new(self start_state, self accept_states, self rulebook)
  )
  isAccepts := method(string,
    dfa := toDFA
    dfa readString(string)
    dfa isAccepting
  )
  new := method(start_state, accept_states, rulebook,
    design := DFADesign clone
    design start_state := start_state
    design accept_states := accept_states
    design rulebook := rulebook
    design
  )
)

rulebook := DFARulebook new(
  list(
    FARule new(1, 97, 2), FARule new(1, 98, 1),
    FARule new(2, 97, 2), FARule new(2, 98, 3),
    FARule new(3, 97, 3), FARule new(3, 98, 3)
  )
)

dfaDesign := DFADesign new(1, list(3), rulebook)

Sequence test := method(dfaDesign,
  self asString .. " => " .. (dfaDesign isAccepts(self))
)

"a" test(dfaDesign) println
"baa" test(dfaDesign) println
"baba" test(dfaDesign) println
