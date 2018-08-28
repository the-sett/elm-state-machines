module Game exposing (Model, Msg(..), init, main, message, update, view)

import Browser
import GameState exposing (..)
import Html exposing (Html)
import Task



-- An example of it in action.
-- This prints out the model as a cycle of loading, playing, completing then
-- restarting the state machine for a game progresses.
-- The purpose of this is to show how the model changes its type in different
-- states eliminating the need for partsof the model to be Maybes.


type Msg
    = Loaded GameDefinition
    | StartGame
    | Die Int
    | AnotherGo


type alias Model =
    { game : Game
    , previous : List Game -- Holds the list of previous states to print.
    , count : Int -- Used to restrict how many steps this demo runs to avoid infinite looping.
    }


message msg =
    Task.perform identity (Task.succeed msg)


main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { game = loading
      , previous = []
      , count = 5
      }
    , message <| Loaded { boardSize = 100 }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        noop =
            ( model, Cmd.none )

        ( nextGame, cmd ) =
            case ( model.game, msg ) of
                ( Loading loading, Loaded gameDefinition ) ->
                    ( { model | game = toReadyWithGameDefinition gameDefinition loading }
                    , message StartGame
                    )

                ( Ready ready, StartGame ) ->
                    ( { model | game = toInPlayWithPlayState { score = 0, position = [] } ready }
                    , message <| Die 123
                    )

                ( InPlay inPlay, Die finalScore ) ->
                    ( { model | game = toGameOver <| (updatePlayState <| updateScore finalScore) inPlay }
                    , message AnotherGo
                    )

                ( GameOver gameOver, AnotherGo ) ->
                    ( { model | game = toReady gameOver }
                    , message StartGame
                    )

                ( _, _ ) ->
                    noop
    in
    if model.count > 0 then
        ( { nextGame
            | previous = model.game :: model.previous
            , count = model.count - 1
          }
        , cmd
        )

    else
        noop


view : Model -> Html Msg
view model =
    Html.div [] <|
        List.map (\game -> Html.p [] [ Html.text (gameToString game) ]) (List.reverse model.previous)


gameToString : Game -> String
gameToString game =
    case game of
        Loading loading ->
            "Loading"

        Ready ready ->
            "Ready"

        InPlay inPlay ->
            "InPlay"

        GameOver gameOver ->
            "GameOver"
