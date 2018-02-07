module Update3
    exposing
        ( lift
        , eval
        )

{-| Convenience function for lifting an update function for an inner model and
messages, that also returns an additional out parameters into a parent one.

@docs lift
@docs eval

-}


{-| Lifts an update function of type:

    update : submsg -> submodel -> ( submodel, Cmd submsg, outmsg )

Into one that returns:

    (model, Cmd  msg, outmsg)

-}
lift :
    (model -> submodel)
    -> (submodel -> model -> model)
    -> (submsg -> msg)
    -> (submsg -> submodel -> ( submodel, Cmd submsg, outmsg ))
    -> submsg
    -> model
    -> ( model, Cmd msg, outmsg )
lift get set tagger update subMsg model =
    let
        ( updatedSubModel, subCmd, outMsg ) =
            update subMsg (get model)
    in
        ( set updatedSubModel model, Cmd.map tagger subCmd, outMsg )


{-| Allows the output of an update function that returns type:

    (model, Cmd msg, outmsg)

To have its model and out message evaluated in order to produce a new model,
and to create more commands. The commands returned will be appended to those
passed in using Cmd.batch.

-}
eval :
    (outmsg -> model -> ( model, Cmd msg ))
    -> ( model, Cmd msg, outmsg )
    -> ( model, Cmd msg )
eval func ( model, cmds, outMsg ) =
    let
        ( newModel, moreCmds ) =
            func outMsg model
    in
        ( newModel, Cmd.batch [ cmds, moreCmds ] )


{-| Allows the output of an update function that returns type:

    (model, Cmd msg, outmsg)

To have its model and out message evaluated in order to produce a new model,
and to create more commands. The commands returned will be appended to those
passed in using Cmd.batch.

-}
evalMaybe :
    (outMsg -> model -> ( model, Cmd msg ))
    -> Cmd msg
    -> ( model, Cmd msg, Maybe outMsg )
    -> ( model, Cmd msg )
evalMaybe func default ( model, cmds, maybeOutMsg ) =
    let
        ( newModel, moreCmds ) =
            case maybeOutMsg of
                Just outMsg ->
                    func outMsg model

                Nothing ->
                    ( model, default )
    in
        ( newModel, Cmd.batch [ cmds, moreCmds ] )


{-| Allows the output of an update function that returns type:

       (model, Cmd msg, Maybe outmsg)

To have its model and out message evaluated in order to produce a new model,
and to create more commands. The commands returned will be appended to those
passed in using Cmd.batch.

-}
evalResult :
    (outMsg -> model -> ( model, Cmd msg ))
    -> (error -> Cmd msg)
    -> ( model, Cmd msg, Result error outMsg )
    -> ( model, Cmd msg )
evalResult func onErr ( model, cmds, resultOutMsg ) =
    let
        ( newModel, moreCmds ) =
            case resultOutMsg of
                Ok outMsg ->
                    func outMsg model

                Err error ->
                    ( model, onErr error )
    in
        ( newModel, Cmd.batch [ cmds, moreCmds ] )
