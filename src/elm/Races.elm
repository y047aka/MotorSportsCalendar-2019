module Races exposing (Race, RaceCategory, getServerResponse)

import Http
import Iso8601
import Json.Decode as Decode
import Time



-- TYPES


type alias RaceCategory =
    { seriesName : String
    , season : String
    , races : List Race
    }


type alias Race =
    { posix : Time.Posix
    , name : String
    }



-- DECODER


raceCategoryDecoder : Decode.Decoder RaceCategory
raceCategoryDecoder =
    Decode.map3 RaceCategory
        (Decode.field "seriesName" Decode.string)
        (Decode.field "season" Decode.string)
        (Decode.field "races" (Decode.list raceDecoder))


raceDecoder : Decode.Decoder Race
raceDecoder =
    Decode.map2 Race
        (Decode.field "date" Iso8601.decoder)
        (Decode.field "name" Decode.string)



-- API


getServerResponse : (Result Http.Error RaceCategory -> msg) -> String -> Cmd msg
getServerResponse msg url =
    Http.get
        { url = url
        , expect = Http.expectJson msg raceCategoryDecoder
        }
