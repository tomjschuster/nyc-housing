module Project exposing (Id, Name, Project, decoder, name, nameToString)

import Json.Decode as JD
import Json.Decode.Pipeline as JDP


type Project
    = Project Info


type alias Info =
    { id : Id
    , name : Name
    , neighborhood : NeighborhoodId
    , addresses : List Address
    }


type Id
    = Id Int


type Name
    = Name String


type Address
    = Address String


type NeighborhoodId
    = NeighborhoodId Int


name : Project -> Name
name project =
    project
        |> toInfo
        |> .name


nameToString : Name -> String
nameToString (Name projectName) =
    projectName


toInfo : Project -> Info
toInfo (Project info) =
    info


decoder : JD.Decoder Project
decoder =
    Info
        |> JD.succeed
        |> JDP.required "id" projectIdDecoder
        |> JDP.required "name" projectNameDecoder
        |> JDP.required "neighborhoodId" neighborhoodIdDecoder
        |> JDP.required "addresses" (JD.list addressDecoder)
        |> JD.map Project


projectIdDecoder : JD.Decoder Id
projectIdDecoder =
    JD.map Id JD.int


projectNameDecoder : JD.Decoder Name
projectNameDecoder =
    JD.map Name JD.string


neighborhoodIdDecoder : JD.Decoder NeighborhoodId
neighborhoodIdDecoder =
    JD.map NeighborhoodId JD.int


addressDecoder : JD.Decoder Address
addressDecoder =
    JD.map Address JD.string
