module Main exposing (main)

import Browser
import Html exposing (Html, li, text, ul)
import Http
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Project exposing (Project)
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


getProjects : Http.Request (List Project)
getProjects =
    Http.get "/api/projects" (JD.list Project.decoder)


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
            let
                _ =
                    Debug.log "err" err
            in
            ( [], Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "NYC Housing"
    , body = [ ul [] (List.map (Project.name >> viewProject) model) ]
    }


viewProject : Project.Name -> Html Msg
viewProject projectName =
    li [] [ text <| Project.nameToString <| projectName ]
