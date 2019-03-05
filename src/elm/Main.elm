import Browser
--import Html exposing (Html, text, node, div, header, section, nav, footer, h1, h2, p, a, ul, li, img)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, optional, hardcoded)

main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


-- MODEL

type alias Model =
    { userState : UserState
    }

type UserState
    = Init
    | Loaded Races
    | Failed Http.Error

init : () -> (Model, Cmd Msg)
init _ =
    ( Model Init
    , ppp
    )


-- UPDATE

type Msg
    = Recieve (Result Http.Error Races)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Recieve (Ok races) ->
            ( { model | userState = Loaded races }, Cmd.none )
        
        Recieve (Err error) ->
            ( { model | userState = Failed error }, Cmd.none )


ppp : Cmd Msg
ppp =
    Http.get
        { url = "https://y047aka.github.io/MotorSportsData/schedules/F1_2019.json"
        , expect = Http.expectJson Recieve racesDecoder
        }


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ siteHeader
        , node "main" []
            [ section []
                [ case model.userState of
                    Init ->
                        text ""
                    
                    Loaded races ->
                        table [ class "heatmap" ]
                            [ tr []
                                [ th [] [ text "Pos" ]
                                , th [] [ text "#" ]
                                ]
                            , tbody [] (List.map viewRaces races)
                            ]
                    
                    Failed error ->
                        div [] [ text (Debug.toString error) ]
                ]
            , links
            , repositories
            ]
        , siteFooter
        ]

viewRaces d =
    tr []
        [ td [] [ text d.date ]
        , td [] [ text d.name ]
        ]

siteHeader : Html Msg
siteHeader =
    Html.header [ class "site-header" ]
        [ h1 [] [ text "Motor Sports Calendar 2019" ]
        ]

links : Html Msg
links =
    section []
        [ h1 [] [ text "Links" ]
        , h2 [] [ text "FIA" ]
        , ul []
            [ li []
                [ a [ href "https://www.formula1.com/en/racing/2019.html", target "_blank" ]
                    [ text "The complete 2019 F1 Championship calendar| Formula 1®" ]
                ]
            , li []
                [ a [ href "https://www.fiawec.com/en/calendar/80", target "_blank" ]
                    [ text "Calendar - FIA World Endurance Championship" ]
                ]
            , li []
                [ a [ href "https://www.fiaformulae.com/en/championship/race-calendar", target "_blank" ]
                    [ text "Race Calendar | FIA Formula E" ]
                ]
            , li []
                [ a [ href "https://www.wrc.com/en/wrc/calendar/calendar/page/671-29772-16--.html", target "_blank" ]
                    [ text "Rally Calendar Overview | WRC Start Dates | WRC Info - wrc.com" ]
                ]
            ]
        , h2 [] [ text "FIM" ]
        , ul []
            [ li []
                [ a [ href "http://www.motogp.com/en/calendar", target "_blank" ]
                    [ text "MotoGP 2019 calendar - Circuits, the schedule and information about every Grand Prix | MotoGP™" ]
                ]
            ]
        , h2 [] [ text "America" ]
        , ul []
            [ li []
                [ a [ href "https://www.indycar.com/Schedule", target "_blank" ]
                    [ text "Schedule - Verizon IndyCar Series, Indy Lights, Pro Mazda & Cooper Tires USF2000" ]
                ]
            , li []
                [ a [ href "https://sportscarchampionship.imsa.com/schedule-results/race-schedule", target "_blank" ]
                    [ text "Schedule | WeatherTech SportsCar Championship" ]
                ]
            , li []
                [ a [ href "https://www.nascar.com/monster-energy-nascar-cup-series/2019/schedule/", target "_blank" ]
                    [ text "2019 Monster Energy NASCAR Cup Series Schedule | NASCAR.com" ]
                ]
            ]
        , h2 [] [ text "Japan" ]
        , ul []
            [ li []
                [ a [ href "https://supergt.net/races", target "_blank" ]
                    [ text "Races | SUPER GT OFFICIAL WEBSITE" ]
                ]
            , li []
                [ a [ href "https://superformula.net/sf2/en/race2019/", target "_blank" ]
                    [ text "Race Calendar 2019 | SUPER FORMULA Official Website" ]
                ]
            ]
        ]

repositories : Html Msg
repositories =
    section []
        [ h1 [] [ text "Repositories" ]
        , h2 [] [ text "Program:" ]
        , a [ href "https://github.com/y047aka/MotorSportsCalendar", target "_blank" ] [ text "https://github.com/y047aka/MotorSportsCalendar" ]
        , h2 [] [ text "Data:" ]
        , a [ href "https://github.com/y047aka/MotorSportsData/tree/master/schedules", target "_blank" ] [ text "https://github.com/y047aka/MotorSportsData/schedules" ]
        ]

siteFooter : Html Msg
siteFooter =
    footer [ class "site-footer" ]
        [ p [ class "copyright"]
            [ text "© 2019 "
            , a [ href "https://y047aka.me", target "_blank" ] [ text "y047aka" ]
            ]
        ]


-- HTTP


-- Data
type alias Race =
    { date : String
    , name : String
    }

type alias Races =
    List Race

race : Decode.Decoder Race
race =
    Decode.succeed Race
        |> required "date" Decode.string
        |> required "name" Decode.string

racesDecoder : Decode.Decoder Races
racesDecoder =
    Decode.field "races" ( Decode.list race )
