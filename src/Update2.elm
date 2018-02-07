module Update2 exposing (eval, lift)

{-| Convenience function for lifting an update function for an inner model
and messages into a parent one.

@docs eval, lift

-}


{-| Lifts an update function of type:

    update : submsg -> submodel -> ( submodel, Cmd submsg )

Into one that returns:

    (model, Cmd  msg)

-}
lift :
    (model -> submodel)
    -> (submodel -> model -> model)
    -> (submsg -> msg)
    -> (submsg -> submodel -> ( submodel, Cmd submsg ))
    -> submsg
    -> model
    -> ( model, Cmd msg )
lift get set tagger update subMsg model =
    let
        ( updatedSubModel, subCmd ) =
            update subMsg (get model)
    in
        ( set updatedSubModel model, Cmd.map tagger subCmd )


{-| Allows the output of an update function that returns type:

    (model, Cmd msg)

To have its model evaluated in order to produce a new model, and to create more
commands. The commands returned will be appended to those passed in using
Cmd.batch.

Note that this allows multiple invokations of the same update function to be
invoked recursively. Beware of causing infinite loops while doing this.

-}
eval :
    (model -> ( model, Cmd msg ))
    -> ( model, Cmd msg )
    -> ( model, Cmd msg )
eval func ( model, cmds ) =
    let
        ( newModel, moreCmds ) =
            func model
    in
        ( newModel, Cmd.batch [ cmds, moreCmds ] )
