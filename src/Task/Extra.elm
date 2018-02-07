module Task.Extra exposing (message)

{-| Extra helper functions for working with Tasks.

@docs message

-}

import Task


{-| A command to pass a message to the Elm router and evaluate it in the next
update cycle.
-}
message : msg -> Cmd msg
message x =
    Task.perform identity (Task.succeed x)
