module Races exposing (Race, RaceCategory, getServerResponseWithCategoryTask)

import Http
import Iso8601
import Json.Decode as Decode
import Task
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


getServerResponseWithCategoryTask : String -> Task.Task Http.Error RaceCategory
getServerResponseWithCategoryTask fileName =
    Http.task
        { method = "GET"
        , headers = []
        , url = fileName
        , body = Http.emptyBody
        , resolver = jsonResolver raceCategoryDecoder
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
