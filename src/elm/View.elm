module View exposing (links, repositories, siteFooter, siteHeader)

import Html exposing (..)
import Html.Attributes exposing (..)


siteHeader : Html msg
siteHeader =
    Html.header [ class "site-header" ]
        [ h1 [] [ text "Motor Sports Calendar 2019" ]
        ]


links : Html msg
links =
    section []
        [ h1 [] [ text "Links" ]
        , h2 [] [ text "FIA" ]
        , ul []
            [ li []
                [ a [ href "https://www.formula1.com/en/racing/2019.html", target "_blank" ]
                    [ h3 [] [ text "Formula 1" ]
                    , text "The complete 2019 F1 Championship calendar"
                    ]
                ]
            , li []
                [ a [ href "https://www.fiawec.com/en/calendar/80", target "_blank" ]
                    [ h3 [] [ text "FIA World Endurance Championship" ]
                    , text "Calendar"
                    ]
                ]
            , li []
                [ a [ href "https://www.fiaformulae.com/en/championship/race-calendar", target "_blank" ]
                    [ h3 [] [ text "FIA Formula E" ]
                    , text "Race Calendar"
                    ]
                ]
            , li []
                [ a [ href "https://www.wrc.com/en/wrc/calendar/calendar/page/671-29772-16--.html", target "_blank" ]
                    [ h3 [] [ text "WRC" ]
                    , text "Rally Calendar Overview"
                    ]
                ]
            ]
        , h2 [] [ text "FIM" ]
        , ul []
            [ li []
                [ a [ href "http://www.motogp.com/en/calendar", target "_blank" ]
                    [ h3 [] [ text "MotoGP" ]
                    , text "MotoGP 2019 calendar"
                    ]
                ]
            ]
        , h2 [] [ text "America" ]
        , ul []
            [ li []
                [ a [ href "https://www.indycar.com/Schedule", target "_blank" ]
                    [ h3 [] [ text "IndyCar" ]
                    , text "Schedule"
                    ]
                ]
            , li []
                [ a [ href "https://sportscarchampionship.imsa.com/schedule-results/race-schedule", target "_blank" ]
                    [ h3 [] [ text "IMSA WSCC" ]
                    , text "Schedule"
                    ]
                ]
            , li []
                [ a [ href "https://www.nascar.com/monster-energy-nascar-cup-series/2019/schedule/", target "_blank" ]
                    [ h3 [] [ text "NASCAR" ]
                    , text "2019 Monster Energy NASCAR Cup Series Schedule"
                    ]
                ]
            ]
        , h2 [] [ text "Japan" ]
        , ul []
            [ li []
                [ a [ href "https://supergt.net/races", target "_blank" ]
                    [ h3 [] [ text "SUPER GT" ]
                    , text "Races"
                    ]
                ]
            , li []
                [ a [ href "https://superformula.net/sf2/en/race2019/", target "_blank" ]
                    [ h3 [] [ text "SUPER FORMULA" ]
                    , text "Race Calendar 2019"
                    ]
                ]
            ]
        ]


repositories : Html msg
repositories =
    section []
        [ h1 [] [ text "Repositories" ]
        , ul []
            [ li []
                [ a [ href "https://github.com/y047aka/MotorSportsCalendar", target "_blank" ]
                    [ h3 [] [ text "Program" ]
                    , text "https://github.com/y047aka/MotorSportsCalendar"
                    ]
                ]
            , li []
                [ a [ href "https://github.com/y047aka/MotorSportsData/tree/master/schedules", target "_blank" ]
                    [ h3 [] [ text "Data" ]
                    , text "https://github.com/y047aka/MotorSportsData/schedules"
                    ]
                ]
            ]
        ]


siteFooter : Html msg
siteFooter =
    footer [ class "site-footer" ]
        [ p [ class "copyright" ]
            [ text "© 2019 "
            , a [ href "https://y047aka.me", target "_blank" ] [ text "y047aka" ]
            ]
        ]
