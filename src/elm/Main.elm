module Main exposing (main)

import Browser
import Html exposing (Html, br, button, caption, div, input, label, node, p, section, span, table, tbody, td, text, th, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Iso8601
import Races exposing (Race, RaceCategory, getServerResponseWithCategoryTask)
import Task
import Time exposing (Month(..), now)
import Time.Extra as Time exposing (Interval(..))
import View


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { userState : UserState
    , resultChunk : List RaceCategory
    , zone : Time.Zone
    , time : Time.Posix
    }


type UserState
    = Init
    | Loaded (List Race)
    | Failed Http.Error


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Init [] Time.utc (Time.millisToPosix 0)
    , getServerResponse
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | GotServerResponse (Result Http.Error (List RaceCategory))
    | Recieve (Result Http.Error (List Race))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        GotServerResponse (Ok categories) ->
            ( { model | resultChunk = categories }, Cmd.none )

        GotServerResponse (Err error) ->
            ( { model | resultChunk = [] }, Cmd.none )

        Recieve (Ok races) ->
            ( { model | userState = Loaded races }, Cmd.none )

        Recieve (Err error) ->
            ( { model | userState = Failed error }, Cmd.none )


getServerResponse : Cmd Msg
getServerResponse =
    let
        categories =
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

        filePathFromItem { category, season } =
            "https://y047aka.github.io/MotorSportsData/schedules/"
                ++ (category ++ "/" ++ category ++ "_" ++ season ++ ".json")
    in
    categories
        |> List.map (filePathFromItem >> getServerResponseWithCategoryTask)
        |> Task.sequence
        |> Task.attempt GotServerResponse



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        utc =
            Time.utc

        start =
            Time.Parts 2019 Jan 1 0 0 0 0 |> Time.partsToPosix utc

        until =
            start |> Time.add Year 1 utc

        sundays =
            Time.range Sunday 1 utc start until
    in
    { title = "MotorSportsCalendar 2019"
    , body =
        [ View.siteHeader
        , node "main"
            []
            [ section []
                [ div []
                    (model.resultChunk
                        |> List.map
                            (\d ->
                                table [ class "heatmap" ]
                                    [ caption [] [ text d.seriesName ]
                                    , tableHeader sundays
                                    , tableBody d.seriesName sundays d.races model.time
                                    ]
                            )
                    )
                ]

            --            , section []
            --                [ case model.userState of
            --                    Init ->
            --                        text ""
            --
            --                    Loaded races ->
            --                        let
            --                            utc = Time.utc
            --                            start = Time.Parts 2019 Jan 1 0 0 0 0 |> Time.partsToPosix utc
            --                            until = start |> Time.add Year 1 utc
            --                            sundays = Time.range Sunday 1 utc start until
            --                        in
            --                            table [ class "heatmap" ]
            --                                [ tableHeader sundays
            --                                , tableBody sundays races model.time
            --                                ]
            --
            --                    Failed error ->
            --                        div [] [ text (Debug.toString error) ]
            --                ]
            , View.links
            ]
        , View.siteFooter
        ]
    }


omissionMonth : Time.Month -> String
omissionMonth month =
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


tableHeader : List Time.Posix -> Html Msg
tableHeader sundays =
    tr []
        (sundays
            |> List.map
                (\posix ->
                    if Time.toDay Time.utc posix <= 7 then
                        th []
                            [ text (Time.toMonth Time.utc posix |> omissionMonth) ]

                    else
                        th [] []
                )
        )


type Weekend
    = Scheduled Race
    | Free
    | Past


isRaceWeek : Time.Posix -> List Race -> Time.Posix -> Weekend
isRaceWeek sundayPosix races currentPosix =
    let
        racesInThisWeek =
            races
                |> List.filter
                    (\raceday ->
                        let
                            racedayPosix =
                                raceday.posix

                            diff =
                                Time.diff Day Time.utc racedayPosix sundayPosix
                        in
                        diff >= 0 && diff < 7
                    )

        isPast =
            Time.diff Day Time.utc sundayPosix currentPosix > 0
    in
    if List.length racesInThisWeek > 0 then
        Scheduled
            (racesInThisWeek
                |> List.reverse
                |> List.head
                |> Maybe.withDefault { name = "name", posix = Time.millisToPosix 0 }
            )

    else if isPast then
        Past

    else
        Free


tableBody : String -> List Time.Posix -> List Race -> Time.Posix -> Html Msg
tableBody seriesName sundays races currentPosix =
    tr []
        (sundays
            |> List.map
                (\sundayPosix ->
                    case isRaceWeek sundayPosix races currentPosix of
                        Scheduled race ->
                            td [ class "raceweek" ]
                                [ label []
                                    [ text (Time.toDay Time.utc sundayPosix |> String.fromInt)
                                    , input [ type_ "checkbox" ] []
                                    , div []
                                        [ text (race.posix |> Iso8601.fromTime |> String.left 10)
                                        , br [] []
                                        , text race.name
                                        ]
                                    ]
                                ]

                        Free ->
                            td [] []

                        Past ->
                            td [ class "past" ] []
                )
        )
