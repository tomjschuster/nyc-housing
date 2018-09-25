module Main exposing (main)

import Browser
import Html exposing (text)


main : Program () Model Msg
main =
    Browser.application
        { init = \_ _ _ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = always NoOp
        , onUrlChange = always NoOp
        }


type Model
    = Model


initialModel : Model
initialModel =
    Model


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "NYC Housing", body = [ text "hello world" ] }
