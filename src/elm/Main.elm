import Browser
import Html exposing (Html, text, node, div, span, section, table, tbody, tr, th, td, label, input, br, button, p)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Iso8601
import Time exposing (Month(..), now)
import Time.Extra as Time exposing (Interval(..))
import Task

import View

main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


-- MODEL

type alias Model =
    { userState : UserState
    , resultChunk : RaceCategories
    , zone : Time.Zone
    , time : Time.Posix
    }

type UserState
    = Init
    | Loaded Races
    | Failed Http.Error

init : () -> (Model, Cmd Msg)
init _ =
    ( Model Init [] Time.utc (Time.millisToPosix 0)
    , qqq
    )

type alias RaceCategory =
    { seriesName : String
    , season : String
    , races : Races
    }

type alias RaceCategories =
    List RaceCategory


-- UPDATE

type Msg
    = Tick Time.Posix
    | GotServerResponse (Result Http.Error RaceCategories)
    | Recieve (Result Http.Error Races)

update : Msg -> Model -> (Model, Cmd Msg)
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
            (
                [ "F1_2019.json"
                , "FormulaE_2018-19.json"
                , "WEC_2018-19.json"
                , "WEC_2019-20.json"
                , "IMSA_2019.json"
                , "IndyCar_2019.json"
                , "NASCAR_2019.json"
                , "SuperFormula_2019.json"
                , "SuperGT_2019.json"
                , "DTM_2019.json"
                , "BlancpainGT_2019.json"
                , "IGTC_2019.json"
                , "WTCR_2019.json"
                , "SuperTaikyu_2019.json"
                , "WRC_2019.json"
                , "MotoGP_2019.json"
                , "AirRace_2019.json"
                ]
                    |> List.map getResultTask
                    |> Task.sequence
            )

getTestServerResponseWithPageTask : String -> Task.Task Http.Error RaceCategory
getTestServerResponseWithPageTask category =
    Http.task
        { method = "GET"
        , headers = []
        , url = "https://y047aka.github.io/MotorSportsData/schedules/" ++ category
        , body = Http.emptyBody
        , resolver = jsonResolver responseDecoder
        , timeout = Nothing
        }

jsonResolver : Decode.Decoder a -> Http.Resolver Http.Error a
jsonResolver decoder =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata body ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ metadata body ->
                    case Decode.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (Http.BadBody (Decode.errorToString err))


responseDecoder : Decode.Decoder RaceCategory
responseDecoder =
    Decode.map3 RaceCategory
        (Decode.field "seriesName" Decode.string)
        (Decode.field "season" Decode.string)
        (Decode.field "races" ( Decode.list raceDecoder ))

-- Data
type alias Race =
    { posix : Time.Posix
    , name : String
    }

type alias Races =
    List Race

raceDecoder : Decode.Decoder Race
raceDecoder =
    Decode.succeed Race
        |> required "date" Iso8601.decoder
        |> required "name" Decode.string



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ View.siteHeader
        , node "main" []
            [ section []
                [
                    let
                        utc = Time.utc
                        start = Time.Parts 2019 Jan 1 0 0 0 0 |> Time.partsToPosix utc
                        until = start |> Time.add Year 1 utc
                        sundays = Time.range Sunday 1 utc start until
                    in
                        div [] (model.resultChunk |> List.map (\d ->
                            table [ class "heatmap" ]
                                [ tableHeader sundays
                                , tableBody d.seriesName sundays d.races model.time
                                ]
                        ))
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

omissionMonth : Time.Month -> String
omissionMonth month =
    case month of
        Jan -> "Jan"
        Feb -> "Feb"
        Mar -> "Mar"
        Apr -> "Apr"
        May -> "May"
        Jun -> "Jun"
        Jul -> "Jul"
        Aug -> "Aug"
        Sep -> "Sep"
        Oct -> "Oct"
        Nov -> "Nov"
        Dec -> "Dec"

tableHeader : List Time.Posix -> Html Msg
tableHeader sundays =
    tr []
        (th [] [] :: (sundays |> List.map (\posix ->
            if Time.toDay Time.utc posix <= 7 then
                th [] 
                    [ span [] [ text (Time.toMonth Time.utc posix |> omissionMonth) ]
                    ]
            else
                th [] []
        )))

type Weekend
    = Scheduled Race
    | Free
    | Past

isRaceWeek : Time.Posix -> Races -> Time.Posix -> Weekend
isRaceWeek sundayPosix races currentPosix =
    let
        racesInThisWeek = races |> List.filter
            (\raceday ->
                let
                    racedayPosix = raceday.posix
                    diff = Time.diff Day Time.utc racedayPosix sundayPosix
                in
                    diff >= 0 && diff < 7
            )

        isPast = Time.diff Day Time.utc sundayPosix currentPosix > 0
    in
        if List.length racesInThisWeek > 0 then
            Scheduled (
                racesInThisWeek
                    |> List.reverse
                    |> List.head
                    |> Maybe.withDefault { name = "name", posix = Time.millisToPosix 0 }
            )
        else if isPast then
            Past
        else
            Free

tableBody : String -> List Time.Posix -> Races -> Time.Posix -> Html Msg
tableBody seriesName sundays races currentPosix =
    tr [] <|
        td [] [ text seriesName ] :: (sundays |> List.map (\sundayPosix ->
            case isRaceWeek sundayPosix races currentPosix of
                Scheduled race ->
                    td [ class "raceweek" ]
                        [ label []
                            [ span [] [ text (Time.toDay Time.utc sundayPosix |> String.fromInt) ]
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
        ))

