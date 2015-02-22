# $ coffee dfa.coffee
# a => false
# baa => false
# baba => true

class FARule
  constructor: (state, character, nextState) ->
    @state = state
    @character = character
    @nextState = nextState
  isAppliesTo: (state, character) ->
    @state == state && @character == character
  follow: ->
    @nextState

class DFARulebook
  constructor: (rules) ->
    @rules = rules
  ruleFor: (state, character) ->
    for rule, i in @rules
      return rule if rule.isAppliesTo(state, character)
  nextState: (state, character) ->
    @ruleFor(state, character).follow()

class DFA
  constructor: (currentState, acceptStates, rulebook) ->
    @currentState = currentState
    @acceptStates = acceptStates
    @rulebook = rulebook
  isAccepting: ->
    @acceptStates.indexOf(@currentState) >= 0
  readCharacter: (character) ->
    @currentState = @rulebook.nextState(@currentState, character)
  readString: (string) ->
    @readCharacter(c) for c in string

class DFADesign
  constructor: (startState, acceptStates, rulebook) ->
    @startState = startState
    @acceptStates = acceptStates
    @rulebook = rulebook
  toDFA: ->
    new DFA(@startState, @acceptStates, @rulebook)
  isAccepts: (string) ->
    dfa = @toDFA()
    dfa.readString(string)
    dfa.isAccepting()

rulebook = new DFARulebook [
  new FARule(1, 'a', 2), new FARule(1, 'b', 1),
  new FARule(2, 'a', 2), new FARule(2, 'b', 3),
  new FARule(3, 'a', 3), new FARule(3, 'b', 3)
]

dfaDesign = new DFADesign(1, [3], rulebook)

test = (s) ->
  console.log "#{s} => #{dfaDesign.isAccepts(s)}"

test('a')
test('baa')
test('baba')
