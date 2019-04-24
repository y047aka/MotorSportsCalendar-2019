module Main exposing (main)

import Browser
import Html exposing (Html, br, button, caption, div, input, label, node, p, section, span, table, tbody, td, text, th, tr)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Iso8601
import Races exposing (Race, RaceCategory, getTestServerResponseWithPageTask)
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
    , qqq
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


qqq : Cmd Msg
qqq =
    let
        getResultTask =
            getTestServerResponseWithPageTask
    in
    Task.attempt GotServerResponse <|
        ([ "F1/F1_2019.json"
         , "FormulaE/FormulaE_2018-19.json"
         , "WEC/WEC_2018-19.json"
         , "WEC/WEC_2019-20.json"
         , "ELMS/ELMS_2019.json"
         , "IMSA/IMSA_2019.json"
         , "IndyCar/IndyCar_2019.json"
         , "NASCAR/NASCAR_2019.json"
         , "SuperFormula/SuperFormula_2019.json"
         , "SuperGT/SuperGT_2019.json"
         , "DTM/DTM_2019.json"
         , "BlancpainGT/BlancpainGT_2019.json"
         , "IGTC/IGTC_2019.json"
         , "WTCR/WTCR_2019.json"
         , "SuperTaikyu/SuperTaikyu_2019.json"
         , "WRC/WRC_2019.json"
         , "MotoGP/MotoGP_2019.json"
         , "AirRace/AirRace_2019.json"
         ]
            |> List.map getResultTask
            |> Task.sequence
        )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "MotorSportsCalendar 2019"
    , body =
        [ View.siteHeader
        , node "main"
            []
            [ section []
                [ let
                    utc =
                        Time.utc

                    start =
                        Time.Parts 2019 Jan 1 0 0 0 0 |> Time.partsToPosix utc

                    until =
                        start |> Time.add Year 1 utc

                    sundays =
                        Time.range Sunday 1 utc start until
                  in
                  div []
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
            , View.repositories
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
