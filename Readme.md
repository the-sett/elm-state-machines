# State machines with phantom types in Elm.

This repo explores the idea of using phantom types to encode the possible states that are allowed to make transitions into some other state in a state machine.

This also demonstrates how this can be used in a more real world setting where states in the machine may have addition data, and functions need to be mapped over that data or updates to it made, rather than just a pure state machine.

### Run It

    > elm-reactor

As the example runs it prints out the states, showing how the shape of the model varies as the state machine runs. This is the point of using the state machine; it only makes available fields in the model that need to exist in any given state. This removes the need for lots of fields in the model to by 'Maybe's, or to have lots of 'Bool' flags in the model to indicate when certain states are valid:

    Loading (State {})
    Ready (State { definition = { boardSize = 100 } })
    InPlay (State { definition = { boardSize = 100 }, play = { score = 0, position = [] } })
    GameOver (State { definition = { boardSize = 100 }, finalScore = 123 })
    Ready (State { definition = { boardSize = 100 } })
