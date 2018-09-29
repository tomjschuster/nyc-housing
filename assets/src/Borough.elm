module Borough
    exposing
        ( Borough
        , bronx
        , brooklyn
        , display
        , manhattan
        , queens
        , statenIsland
        )


type Borough
    = Bronx
    | Brooklyn
    | Manhattan
    | Queens
    | StatenIsland


bronx : Borough
bronx =
    Bronx


brooklyn : Borough
brooklyn =
    Brooklyn


manhattan : Borough
manhattan =
    Manhattan


queens : Borough
queens =
    Queens


statenIsland : Borough
statenIsland =
    StatenIsland


display : Borough -> String
display borough =
    case borough of
        Bronx ->
            "Bronx"

        Brooklyn ->
            "Brooklyn"

        Manhattan ->
            "Manhattan"

        Queens ->
            "Queens"

        StatenIsland ->
            "Staten Island"


fromString : String -> Maybe Borough
fromString string =
    case string of
        "bronx" ->
            Just Bronx

        "brooklyn" ->
            Just Brooklyn

        "manhattan" ->
            Just Manhattan

        "queens" ->
            Just Queens

        "staten_island" ->
            Just StatenIsland

        _ ->
            Nothing
