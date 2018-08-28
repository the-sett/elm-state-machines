module GameState exposing
    ( Game(..)
    , GameDefinition
    , PlayState
    , loading
    , toGameOver
    , toInPlayWithPlayState
    , toReady
    , toReadyWithGameDefinition
    , updateGameDefinition
    , updatePlayState
    , updateScore
    )

import StateMachine exposing (Allowed, State(..))



-- An Example model for a game of some kind.


type alias GameDefinition =
    { boardSize : Int
    }


type alias PlayState =
    { score : Int
    , position : List Int
    }



-- The state definitions have enough typing information to enforce matching
-- states against legal state transitions, and against the available data model
-- in the state.


type Game
    = Loading (State { ready : Allowed } {})
    | Ready (State { inPlay : Allowed } { definition : GameDefinition })
    | InPlay (State { gameOver : Allowed } { definition : GameDefinition, play : PlayState })
    | GameOver (State { ready : Allowed } { definition : GameDefinition, finalScore : Int })



-- State constructors.


loading : Game
loading =
    State {} |> Loading


ready : GameDefinition -> Game
ready definition =
    State { definition = definition } |> Ready


inPlay : GameDefinition -> PlayState -> Game
inPlay definition play =
    State { definition = definition, play = play } |> InPlay


gameOver : GameDefinition -> Int -> Game
gameOver definition score =
    State { definition = definition, finalScore = score } |> GameOver



-- Update functions that can be applied when parts of the model are present.


mapDefinition : (a -> a) -> ({ m | definition : a } -> { m | definition : a })
mapDefinition func =
    \model -> { model | definition = func model.definition }


mapPlay : (a -> a) -> ({ m | play : a } -> { m | play : a })
mapPlay func =
    \model -> { model | play = func model.play }


updateGameDefinition :
    (GameDefinition -> GameDefinition)
    -> State p { m | definition : GameDefinition }
    -> State p { m | definition : GameDefinition }
updateGameDefinition func state =
    StateMachine.map (mapDefinition func) state


updatePlayState :
    (PlayState -> PlayState)
    -> State p { m | play : PlayState }
    -> State p { m | play : PlayState }
updatePlayState func state =
    StateMachine.map (mapPlay func) state


updateScore : Int -> PlayState -> PlayState
updateScore score play =
    { play | score = score }



-- State transition functions that can be applied only to states that are permitted
-- to make a transition.


toReady : State { a | ready : Allowed } { m | definition : GameDefinition } -> Game
toReady (State model) =
    ready model.definition


toReadyWithGameDefinition : GameDefinition -> State { a | ready : Allowed } m -> Game
toReadyWithGameDefinition definition game =
    ready definition


toInPlayWithPlayState : PlayState -> State { a | inPlay : Allowed } { m | definition : GameDefinition } -> Game
toInPlayWithPlayState play (State model) =
    inPlay model.definition play


toGameOver : State { a | gameOver : Allowed } { m | definition : GameDefinition, play : PlayState } -> Game
toGameOver (State model) =
    gameOver model.definition model.play.score
