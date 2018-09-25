module Main exposing (main)

import Browser
import Html exposing (Html, li, text, ul)
import Http
import Json.Decode as JD
import Task exposing (Task)


main : Program () Model Msg
main =
    Browser.application
        { init = \_ _ _ -> ( initialModel, Http.send LoadProjects getProjects )
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = always NoOp
        , onUrlChange = always NoOp
        }


type alias Project =
    { id : Int
    , name : String
    }


projectDecoder : JD.Decoder Project
projectDecoder =
    JD.map2 Project (JD.field "id" JD.int) (JD.field "name" JD.string)


getProjects : Http.Request (List Project)
getProjects =
    Http.get "/projects" (JD.list projectDecoder)


type alias Model =
    List Project


initialModel : Model
initialModel =
    []


type Msg
    = NoOp
    | LoadProjects (Result Http.Error (List Project))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LoadProjects (Ok projects) ->
            ( projects, Cmd.none )

        LoadProjects (Err err) ->
            ( [], Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "NYC Housing", body = [ ul [] (List.map viewProject model) ] }


viewProject : Project -> Html Msg
viewProject project =
    li [] [ text project.name ]
