// $ g++ --std=c++11 -o dfa dfa.cpp
// $ ./dfa
// a => false
// baa => false
// baba => true

#include <algorithm>
#include <initializer_list>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>

typedef int State;

typedef std::vector<State> States;

class FARule
{
public:
    explicit FARule(State state, char c, State nextState) : state_(state), c_(c), nextState_(nextState)
    {
    }

    bool appliesTo(State state, char c) const
    {
        return (state_ == state) && (c_ == c);
    }

    State follow() const
    {
        return nextState_;
    }

    std::string inspect() const
    {
        std::ostringstream oss;
        oss << "#<FARule " << state_ << " --" << c_ << "--> " << nextState_ << ">" << std::flush;
        return oss.str();
    }

private:
    State state_;
    char c_;
    State nextState_;
};

typedef std::vector<FARule> Rules;

class DFARulebook
{
public:
    explicit DFARulebook(const Rules& rules) : rules_(rules)
    {
    }

    const FARule& ruleFor(State state, char c) const
    {
        Rules::const_iterator i = std::find_if(std::begin(rules_), std::end(rules_), [&](const FARule& rule) { return rule.appliesTo(state, c); });
        return *i;
    }

    State nextState(State state, char c) const
    {
        return ruleFor(state, c).follow();
    }

private:
    Rules rules_;
};

class DFA
{
public:
    explicit DFA(State currentState, States acceptStates, DFARulebook rullbook) : currentState_(currentState), acceptStates_(acceptStates), rullbook_(rullbook)
    {
    }

    bool isAccepting() const
    {
        return std::find(std::begin(acceptStates_), std::end(acceptStates_), currentState_) != std::end(acceptStates_);
    }

    void readCharacter(char c)
    {
        currentState_ = rullbook_.nextState(currentState_, c);
    }

    void readString(const std::string& s)
    {
        std::for_each(std::begin(s), std::end(s), [&](char c) { this->readCharacter(c); });
    }

private:
    State currentState_;
    States acceptStates_;
    DFARulebook rullbook_;
};

class DFADesign
{
public:
    explicit DFADesign(State currentState, States acceptStates, DFARulebook rullbook) : currentState_(currentState), acceptStates_(acceptStates), rullbook_(rullbook)
    {
    }

    DFA toDFA() const
    {
        return DFA(currentState_, acceptStates_, rullbook_);
    }

    bool isAccepts(const std::string& s) const
    {
        DFA dfa = toDFA();
        dfa.readString(s);
        return dfa.isAccepting();
    }

private:
    State currentState_;
    States acceptStates_;
    DFARulebook rullbook_;
};

void test(std::ostream& out, const DFADesign& design, const std::string& s)
{
    out << s << " => " << design.isAccepts(s) << "\n";
}

int main(int argc, char* argv[])
{
    Rules rules =
    {
        FARule(1, 'a', 2), FARule(1, 'b', 1),
        FARule(2, 'a', 2), FARule(2, 'b', 3),
        FARule(3, 'a', 3), FARule(3, 'b', 3)
    };

    DFARulebook rulebook(rules);

    DFADesign design(1, {3}, rulebook);

    std::cout << std::boolalpha;
    test(std::cout, design, "a");
    test(std::cout, design, "baa");
    test(std::cout, design, "baba");

    return 0;
}
