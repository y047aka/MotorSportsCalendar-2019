module View exposing (links, siteFooter, siteHeader)

import Html exposing (Html, a, div, footer, h1, h2, h3, li, p, section, text, ul)
import Html.Attributes exposing (class, href, target)


siteHeader : Html msg
siteHeader =
    Html.header [ class "site-header" ]
        [ h1 [] [ text "Motor Sports Calendar 2019" ]
        ]


links : Html msg
links =
    section [ class "external-links" ]
        [ h1 [] [ text "Links" ]
        , h2 [] [ text "FIA" ]
        , div [ class "links" ]
            (let
                series =
                    [ { name = "Formula 1", url = "https://www.formula1.com/en/racing/2019.html" }
                    , { name = "WEC", url = "https://www.fiawec.com/en/calendar/80" }
                    , { name = "Formula E", url = "https://www.fiaformulae.com/en/championship/race-calendar" }
                    , { name = "WRC", url = "https://www.wrc.com/en/wrc/calendar/calendar/page/671-29772-16--.html" }
                    ]
             in
             series
                |> List.map
                    (\item ->
                        a [ href item.url, target "_blank" ]
                            [ h3 [] [ text item.name ] ]
                    )
            )
        , h2 [] [ text "FIM" ]
        , div [ class "links" ]
            [ a [ href "http://www.motogp.com/en/calendar", target "_blank" ]
                [ h3 [] [ text "MotoGP" ] ]
            ]
        , h2 [] [ text "America" ]
        , div [ class "links" ]
            (let
                series =
                    [ { name = "IndyCar", url = "https://www.indycar.com/Schedule" }
                    , { name = "IMSA WSCC", url = "https://sportscarchampionship.imsa.com/schedule-results/race-schedule" }
                    , { name = "NASCAR", url = "https://www.nascar.com/monster-energy-nascar-cup-series/2019/schedule/" }
                    ]
             in
             series
                |> List.map
                    (\item ->
                        a [ href item.url, target "_blank" ]
                            [ h3 [] [ text item.name ] ]
                    )
            )
        , h2 [] [ text "Japan" ]
        , div [ class "links" ]
            [ a [ href "https://supergt.net/races", target "_blank" ]
                [ h3 [] [ text "SUPER GT" ] ]
            , a [ href "https://superformula.net/sf2/en/race2019/", target "_blank" ]
                [ h3 [] [ text "SUPER FORMULA" ] ]
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
