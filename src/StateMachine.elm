module StateMachine
    exposing
        ( Allowed
        , State(..)
        , map
        , untag
        )

{-| Reusable state machine concepts.

@docs Allowed, State, map, untag

-}


{-| This type is used as a marker to annotate the type of a State with a set of
states that it can legally transition into.
-}
type Allowed
    = Allowed


{-| State captures the type of a state with its type annotated with the states
that it can transition into as a phantom type, and the data model that the state
has as a concrete part of the state model.
-}
type State trans model
    = State model



-- Permitted operations on State that do not allow arbitrary states to be
-- constructed in order to bypass the type checking on state transitions.


{-| Maps a function over the model within a State.
-}
map : (a -> b) -> State tag a -> State tag b
map f (State x) =
    State (f x)


{-| Unboxes the model from within a State.
-}
untag : State tag value -> value
untag (State x) =
    x
