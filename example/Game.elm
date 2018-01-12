module Game exposing (..)

import Html exposing (Html)
import Task
import GameState exposing (..)


-- An example of it in action.


type Msg
    = Loaded GameDefinition
    | StartGame
    | Die Int
    | AnotherGo


type alias Model =
    { game : Game
    , previous : List Game
    , count : Int
    }


message msg =
    Task.perform identity (Task.succeed msg)


main =
    Html.program
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }


init : ( Model, Cmd Msg )
init =
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
            case ( model.game, (Debug.log "update" msg) ) of
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
        List.map (\game -> Html.p [] [ Html.text (toString game) ]) (List.reverse model.previous)
