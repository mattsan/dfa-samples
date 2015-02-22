-- $ ghc --make dfa
-- $ ./dfa
-- a => False
-- baa => False
-- baba => True

import Data.List

data FARule = FARule Integer Char Integer deriving Show
data DFARulebook = DFARulebook [FARule] deriving Show
data DFA = DFA Integer [Integer] DFARulebook deriving Show

appliesTo (FARule s c n) s' c' = s == s' && c == c'
follow (FARule s c n) = n

ruleFor (DFARulebook (r:rs)) s' c' = if (appliesTo r s' c') then r else ruleFor (DFARulebook rs) s' c'
nextState rulebook s' c' = follow $ ruleFor rulebook s' c' 

isAccepting (DFA s as _) = s `elem` as 
readCharacter (DFA s as rulebook) c' = DFA (nextState rulebook s c') as rulebook
readString dfa ss = foldl readCharacter dfa ss

isAccepts dfa ss = isAccepting $ readString dfa ss

rules = [ FARule 1 'a' 2, FARule 1 'b' 1,
          FARule 2 'a' 2, FARule 2 'b' 3,
          FARule 3 'a' 3, FARule 3 'b' 3 ]
rulebook = DFARulebook rules

test s =
  putStrLn $ s ++ " => " ++ (show $ isAccepts (DFA 1 [3] rulebook) s)

main = do
  test "a"
  test "baa"
  test "baba"
