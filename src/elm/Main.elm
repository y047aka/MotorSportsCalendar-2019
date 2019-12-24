module Main exposing (main)

import Browser
import Html exposing (Html, br, caption, div, input, label, li, nav, section, table, td, text, th, tr, ul)
import Html.Attributes exposing (checked, class, for, id, type_, value)
import Html.Events exposing (onCheck)
import Http
import Iso8601
import List.Extra as List
import Page
import Races exposing (Race, Season, getServerResponse)
import Task
import Time exposing (Month(..))
import Time.Extra as Time exposing (Interval(..))
import Weekend exposing (Weekend(..))


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { raceCategories : List Season
    , unselectedCategories : List String
    , zone : Time.Zone
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        filePathFromItem { category, season } =
            "https://y047aka.github.io/MotorSportsData/schedules/"
                ++ (category ++ "/" ++ category ++ "_" ++ season ++ ".json")
    in
    ( Model [] [] Time.utc (Time.millisToPosix 0)
    , Cmd.batch <|
        Task.perform AdjustTimeZone Time.here
            :: Task.perform Tick Time.now
            :: List.map (filePathFromItem >> getServerResponse GotServerResponse)
                [ { category = "F1", season = "2019" }
                , { category = "FormulaE", season = "2018-19" }
                , { category = "WEC", season = "2018-19" }
                , { category = "WEC", season = "2019-20" }
                , { category = "ELMS", season = "2019" }
                , { category = "IMSA", season = "2019" }
                , { category = "IndyCar", season = "2019" }
                , { category = "NASCAR", season = "2019" }
                , { category = "SuperFormula", season = "2019" }
                , { category = "SuperGT", season = "2019" }
                , { category = "DTM", season = "2019" }
                , { category = "BlancpainGT", season = "2019" }
                , { category = "IGTC", season = "2019" }
                , { category = "WTCR", season = "2019" }
                , { category = "SuperTaikyu", season = "2019" }
                , { category = "WRC", season = "2019" }
                , { category = "MotoGP", season = "2019" }
                , { category = "AirRace", season = "2019" }
                ]
    )



-- UPDATE


type Msg
    = AdjustTimeZone Time.Zone
    | Tick Time.Posix
    | UpdateCategories String Bool
    | GotServerResponse (Result Http.Error Season)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AdjustTimeZone newZone ->
            ( { model | zone = newZone }, Cmd.none )

        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        UpdateCategories category isChecked ->
            let
                updatedCategories =
                    if isChecked then
                        List.filter (\d -> not (d == category)) model.unselectedCategories

                    else
                        category :: model.unselectedCategories
            in
            ( { model | unselectedCategories = updatedCategories }, Cmd.none )

        GotServerResponse (Ok category) ->
            ( { model | raceCategories = List.sortWith compare (category :: model.raceCategories) }
            , Cmd.none
            )

        GotServerResponse (Err error) ->
            ( model, Cmd.none )


compare : Season -> Season -> Order
compare a b =
    let
        enumarate =
            [ "F1"
            , "Formula E"
            , "WEC"
            , "WEC"
            , "ELMS"
            , "IMSA WSCC"
            , "IndyCar"
            , "NASCAR"
            , "SUPER FORMULA"
            , "SUPER GT"
            , "DTM"
            , "Blancpain GT"
            , "IGTC"
            , "WTCR"
            , "Super Taikyu"
            , "WRC"
            , "MotoGP"
            , "Red Bull Air Race"
            ]
    in
    if a.seriesName == b.seriesName then
        EQ

    else
        case List.dropWhile (\x -> x /= a.seriesName && x /= b.seriesName) enumarate of
            x :: _ ->
                if x == a.seriesName then
                    LT

                else
                    GT

            _ ->
                LT



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "MotorSportsCalendar 2019"
    , body = Page.view (viewHeatMap model)
    }


viewHeatMap : Model -> Html Msg
viewHeatMap model =
    let
        start =
            Time.Parts 2019 Jan 1 0 0 0 0 |> Time.partsToPosix model.zone

        until =
            start |> Time.add Year 1 model.zone

        sundays =
            Time.range Sunday 1 model.zone start until
    in
    section [ class "annual" ] <|
        viewHeatMapHeader model.unselectedCategories
            :: (model.raceCategories
                    |> List.filter (\series -> not (List.member series.seriesName model.unselectedCategories))
                    |> List.map
                        (\series ->
                            let
                                tableCaption =
                                    case series.season of
                                        "2019" ->
                                            series.seriesName

                                        _ ->
                                            series.seriesName ++ " (" ++ series.season ++ ")"
                            in
                            table []
                                [ caption [] [ text tableCaption ]
                                , viewTicks sundays
                                , viewRaces sundays series.races model.time
                                ]
                        )
               )


viewHeatMapHeader : List String -> Html Msg
viewHeatMapHeader unselectedCategories =
    let
        listItem d =
            li []
                [ input
                    [ id d.id
                    , type_ "checkbox"
                    , value d.value
                    , checked <| not (List.member d.value unselectedCategories)
                    , onCheck <| UpdateCategories d.value
                    ]
                    []
                , label [ for d.id ] [ text d.value ]
                ]
    in
    nav []
        [ ul [] <|
            List.map listItem
                [ { id = "f1", value = "F1" }
                , { id = "formulaE", value = "Formula E" }
                , { id = "wec", value = "WEC" }
                , { id = "elms", value = "ELMS" }
                , { id = "wscc", value = "IMSA WSCC" }
                , { id = "indycar", value = "IndyCar" }
                , { id = "nascar", value = "NASCAR" }
                , { id = "superFormula", value = "SUPER FORMULA" }
                , { id = "superGT", value = "SUPER GT" }
                , { id = "dtm", value = "DTM" }
                , { id = "blancpain", value = "Blancpain GT" }
                , { id = "igtc", value = "IGTC" }
                , { id = "wtcr", value = "WTCR" }
                , { id = "superTaikyu", value = "Super Taikyu" }
                , { id = "wrc", value = "WRC" }
                , { id = "motoGP", value = "MotoGP" }
                , { id = "rbar", value = "Red Bull Air Race" }
                ]
        ]


viewTicks : List Time.Posix -> Html Msg
viewTicks sundays =
    let
        isBeginningOfMonth posix =
            Time.toDay Time.utc posix <= 7

        tableheader posix =
            if isBeginningOfMonth posix then
                th []
                    [ text <| stringFromMonth (Time.toMonth Time.utc posix) ]

            else
                th [] []
    in
    tr [] <|
        List.map tableheader sundays


viewRaces : List Time.Posix -> List Race -> Time.Posix -> Html Msg
viewRaces sundays races currentPosix =
    let
        tdCell sundayPosix =
            case Weekend.weekend sundayPosix races currentPosix of
                Scheduled race ->
                    td [ class "raceweek" ]
                        [ label []
                            [ text <| String.fromInt (Time.toDay Time.utc sundayPosix)
                            , input [ type_ "checkbox" ] []
                            , div []
                                [ text <| String.left 10 (Iso8601.fromTime race.posix)
                                , br [] []
                                , text race.name
                                ]
                            ]
                        ]

                Free ->
                    td [] []

                Past ->
                    td [ class "past" ] []
    in
    tr [] <|
        List.map tdCell sundays



-- PRIVATE FUNCTIONS


stringFromMonth : Time.Month -> String
stringFromMonth month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"
