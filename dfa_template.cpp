// $ g++ --std=c++11 -c dfa_template.cpp 
// dfa_template.cpp:107:1: error: static_assert failed "'a' was not accepted"
// dfa_template.cpp:110:1: error: static_assert failed "'baa' was not accepted"
// dfa_template.cpp:114:1: error: static_assert failed "'baba' was accepted"

template<int State, char Character, int NextState>
struct FARule
{
    static const int state = State;
    static const char character = Character;
    static const int nextState = NextState;

    template<int S, char C>
    struct appliesTo
    {
        static const bool value = (state == S) && (character == C);
    };

    struct follow
    {
        static const int value = NextState;
    };
};

template<int S, char C, int N, typename RS>
struct Rules
{
    struct Head
    {
        typedef FARule<S, C, N> Rule;
    };

    typedef RS Tail;
};

template<bool C, typename T, typename F> struct If { typedef T Type; };
template<typename T, typename F> struct If<false, T, F> { typedef F Type; };

template<typename Rules>
struct DFARulebook
{
    template<int S, char C>
    struct ruleFor
    {
        typedef typename If<Rules::Head::Rule::template appliesTo<S, C>::value,
          typename Rules::Head,
          typename DFARulebook<typename Rules::Tail>::template ruleFor<S, C>
        >::Type::Rule Rule;
    };

    template<int S, char C>
    struct nextState
    {
        static const int value = ruleFor<S, C>::Rule::follow::value;
    };
};

template<int State, bool AcceptStates(int), typename Rulebook>
struct DFA
{
    struct isAccepting
    {
        static const bool value = AcceptStates(State);
    };

    template<char C>
    struct readCharacter
    {
        static const int nextState = Rulebook::template nextState<State, C>::value;
        typedef DFA<nextState, AcceptStates, Rulebook> Type;
    };

    template<char S(int), int N = 0, int F = -1>
    struct readString
    {
        static const char C = S(N);
        typedef typename readCharacter<S(N)>::Type::template readString<S, N + 1, S(N + 1)>::Type Type;
    };

    template<char S(int), int N>
    struct readString<S, N, '\0'>
    {
        typedef DFA Type;
    };

    template<char S(int)>
    struct isAccepts
    {
        static const bool value = readString<S>::Type::isAccepting::value;
    };
};

struct Nil {};

typedef DFARulebook<
  Rules<1, 'a', 2, Rules<1, 'b', 1,
  Rules<2, 'a', 2, Rules<2, 'b', 3,
  Rules<3, 'a', 3, Rules<3, 'b', 3,
  Nil>>>>>>
> Rulebook;

constexpr char a(int n) { return "a"[n]; }
constexpr char baa(int n) { return "baa"[n]; }
constexpr char baba(int n) { return "baba"[n]; }

constexpr bool acceptStates(int n) { return n == 3; }

const bool a_is_accepted = DFA<1, acceptStates, Rulebook>::template isAccepts<a>::value;
const bool baa_is_accepted = DFA<1, acceptStates, Rulebook>::template isAccepts<baa>::value;
const bool baba_is_accepted = DFA<1, acceptStates, Rulebook>::template isAccepts<baba>::value;

static_assert(a_is_accepted, "'a' was not accepted");
static_assert(!a_is_accepted, "'a' was accepted");

static_assert(baa_is_accepted, "'baa' was not accepted");
static_assert(!baa_is_accepted, "'baa' was accepted");

static_assert(baba_is_accepted, "'baba' was not accepted");
static_assert(!baba_is_accepted, "'baba' was accepted");
