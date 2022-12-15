module Weekend exposing (Weekend(..), weekend)

import Races exposing (Race)
import Time
import Time.Extra as Time exposing (Interval(..))


type Weekend
    = Scheduled Race
    | Free
    | Past


weekend : Time.Posix -> List Race -> Time.Posix -> Weekend
weekend sundayPosix races currentPosix =
    let
        isRaceWeek raceday =
            let
                diff =
                    Time.diff Day Time.utc raceday.posix sundayPosix
            in
            diff >= 0 && diff < 7

        racesInThisWeek =
            races
                |> List.filter isRaceWeek

        hasRace =
            List.length racesInThisWeek > 0

        isPast =
            Time.diff Day Time.utc sundayPosix currentPosix > 0
    in
    if hasRace then
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
