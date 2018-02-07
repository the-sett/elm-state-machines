# State machines with phantom types in Elm.

This package assists with expressing state machines using phantom types to encode the possible state
transitions that can be made between states, in such a way that the compiler can enforce them.

It is a very minimal package and is similar to [ http://package.elm-lang.org/packages/joneshf/elm-tagged/latest ].
It exposes a type definition for modelling states with a phantom type:

    type State trans model
        = State model

and provides a 'map' operation over this as well as an 'untag' operation to extract the model.

# Example

The example/ folder demonstrates how this can be used to define a state machine, and export type safe functions
that can only be used to manipulate the state machine in legal ways. This package is as much about providing a
pattern for writing state machines as it is about providing a library to help with writing them; the amount of
code in the library is tiny.

In order to define the legal state transitions in the machine, set up the phantom type 'trans' as record types
with fields named by the states that they can transition into, and give them the 'Allowed' type. Use the 'model'
type to define the shape of the data model that each state has. For example:

    type Game
        = Loading (State { ready : Allowed } {})
        | Ready (State { inPlay : Allowed } { definition : GameDefinition })
        | InPlay (State { gameOver : Allowed } { definition : GameDefinition, play : PlayState })
        | GameOver (State { ready : Allowed } { definition : GameDefinition, finalScore : Int })


### Run It

    > cd example
    > elm-reactor

As the example runs it prints out the states, showing how the shape of the model varies as the state machine runs.
This is the point of using the state machine; it only makes available fields in the model that need to exist in any
given state. This removes the need for lots of fields in the model to by 'Maybe's, or to have lots of 'Bool' flags
in the model to indicate when certain states are valid:

    Loading (State {})
    Ready (State { definition = { boardSize = 100 } })
    InPlay (State { definition = { boardSize = 100 }, play = { score = 0, position = [] } })
    GameOver (State { definition = { boardSize = 100 }, finalScore = 123 })
    Ready (State { definition = { boardSize = 100 } })
